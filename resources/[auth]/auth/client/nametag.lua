local playerNames = {}

RegisterNetEvent('auth:playerName', function(playerId, username)
    playerNames[playerId] = username
end)

RegisterNetEvent('auth:playerNameRemove', function(playerId)
    playerNames[playerId] = nil
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('auth:requestNames')
end)

Citizen.CreateThread(function()
    while true do
        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)

        for playerId, username in pairs(playerNames) do
            local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))

            if targetPed and DoesEntityExist(targetPed) then
                local targetCoords = GetEntityCoords(targetPed)
                local dist = #(myCoords - targetCoords)

                if dist < 30.0 then
                    local x, y, z = table.unpack(targetCoords)

                    DrawText3D(x, y, z + 1.0, username, 255, 255, 255, 255)
                end
            end
        end

        Citizen.Wait(0)
    end
end)

function DrawText3D(x, y, z, text, r, g, b, a)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)

    if onScreen then
        SetTextScale(0.55, 0.55)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(r, g, b, a)
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry('STRING')
        AddTextComponentString(text)
        DrawText(sx, sy)
    end
end
