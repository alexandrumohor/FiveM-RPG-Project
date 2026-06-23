local chatOpen = false
local chatMessages = {}

RegisterNUICallback('chatMessage', function(data, cb)
    if data.message and data.message ~= '' then
        TriggerServerEvent('chat:sendMessage', data.message)
    end
    cb('ok')
end)

RegisterNUICallback('chatClose', function(data, cb)
    chatOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('chat:receiveMessage', function(username, message)
    SendNUIMessage({
        action = 'chatMessage',
        username = username,
        message = message,
    })
end)

Citizen.CreateThread(function()
    while true do
        if IsPlayerAuthenticated() then
            if IsControlJustPressed(0, 245) then -- T key
                chatOpen = true
                SetNuiFocus(true, false)
                SendNUIMessage({ action = 'chatOpen' })
            end
        end
        Citizen.Wait(0)
    end
end)
