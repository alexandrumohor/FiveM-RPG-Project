Spawn = {}

local frozen = false

function Spawn.Freeze()
    frozen = true
    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)
    FreezeEntityPosition(ped, true)
    SetPlayerInvincible(PlayerId(), true)
end

function Spawn.Unfreeze()
    frozen = false
    local ped = PlayerPedId()

    SetEntityCoords(ped, Config.SpawnCoords.x, Config.SpawnCoords.y, Config.SpawnCoords.z, false, false, false, true)
    SetEntityHeading(ped, Config.SpawnCoords.w)

    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)
    SetPlayerInvincible(PlayerId(), false)
end

Citizen.CreateThread(function()
    while true do
        if frozen then
            local ped = PlayerPedId()
            DisableAllControlActions(0)
            SetEntityVisible(ped, false, false)
            FreezeEntityPosition(ped, true)
        end
        Citizen.Wait(frozen and 0 or 500)
    end
end)
