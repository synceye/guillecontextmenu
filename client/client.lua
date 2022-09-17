function log(ty, t)
    if ty == "error" then
        print("^3["..GetCurrentResourceName().."] ^1[ERROR] "..t)
    else
        print("^2["..GetCurrentResourceName().."] ^2[INFO]^8 "..t)
    end
end

local GUI = {}
GUI.Time = 0

local isThis = {}
isThis['selected'] = 1
isThis['data'] = {}

RegisterNetEvent("ui:create")
AddEventHandler("ui:create", function(title, data)
    if not isThis.menuOpened then
        local datas = -1
        if title == nil then
            log("error", "No Title!")
            return
        end
        local toSend = {}
        for k,v in pairs(data) do
            datas = datas + 1
            if v.toDo == nil then
                log("error", "Event not defined at: "..v.text)
                return
            end
            isThis['data'][k] = v['toDo']
            table.insert(toSend, {text = v['text'], icon = v['icon']})
        end
        isThis['data'] = data
        SendNUIMessage({
            title = title;
            data = toSend;
        })
        isThis.menuOpened = true
        TriggerEvent("openMenu", datas)
    end
end)

RegisterNUICallback("close", function(cb)
    PlaySoundFrontend(-1, 'Highlight_Cancel','DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    isThis.menuOpened = false
end)

RegisterNetEvent('ui:close')
AddEventHandler('ui:close', function()
    if (GetGameTimer() - GUI.Time) > 150 then
        SendNUIMessage({
            move = "no"
        })
        isThis['selected'] = 1
        isThis['data'] = {}
    end
end)

RegisterNetEvent("openMenu")
AddEventHandler("openMenu", function(num)
    local selected = 0
    CreateThread(function()
        Wait(500)
        while isThis.menuOpened do
            if IsControlJustPressed(0, 18) and (GetGameTimer() - GUI.Time) > 500 then
                SendNUIMessage({
                    toExecute = tostring(selected);
                })

                local args = isThis['data'][isThis['selected']]['args']
                local event = isThis['data'][isThis['selected']]['toDo']
                local isClient = isThis['data'][isThis['selected']]['isClient']
                if isClient == nil then isClient = true end

                if not args then
                    if isClient then TriggerEvent(event) else TriggerServerEvent(event) end
                else
                    if isClient then TriggerEvent(event, UnpackParams(args)) else TriggerServerEvent(event, UnpackParams(args)) end                     
                end

                isThis['selected'] = 1
                isThis['data'] = {}
            end

            if IsControlJustPressed(0, 177) and (GetGameTimer() - GUI.Time) > 150 then
                SendNUIMessage({
                    move = "no"
                })
                isThis['selected'] = 1
                isThis['data'] = {}
            end

            if IsControlJustPressed(0, 27) and (GetGameTimer() - GUI.Time) > 150 then
                if selected == 0 then
                    selected = num
                    SendNUIMessage({
                        selected = tostring(num);
                    })
                    
                elseif selected ~= 0 then
                    selected = selected - 1
                    SendNUIMessage({
                        selected = tostring(selected);
                    })
                end

                if isThis['selected'] == 1 then
                    isThis['selected'] = num + 1
                else
                    isThis['selected'] = isThis['selected'] - 1
                end
                
            end

            if IsControlJustPressed(0, 173) and (GetGameTimer() - GUI.Time) > 150 then
                if selected == num then
                    selected = 0
                    SendNUIMessage({
                        selected = tostring(0);
                    })
                elseif selected ~= num then
                    selected = selected + 1
                    SendNUIMessage({
                        selected = tostring(selected);
                    })
                end

                if isThis['selected'] == (num + 1) then
                    isThis['selected'] = 1
                else
                    isThis['selected'] = isThis['selected'] + 1
                end
                
            end
            Wait(0)
        end
    end)
end)

UnpackParams = function(arguments, i)
    if not arguments then return end
    local index = i or 1
    
    if index <= #arguments then
        return arguments[index], UnpackParams(arguments, index + 1)
    end
end
