Spawn = {}

local frozen = false

function Spawn.Freeze()
    frozen = true
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    SetPlayerInvincible(PlayerId(), true)
end

function Spawn.Unfreeze()
    frozen = false

    local model = GetHashKey('mp_m_freemode_01')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    local ped = PlayerPedId()

    SetEntityCoords(ped, Config.SpawnCoords.x, Config.SpawnCoords.y, Config.SpawnCoords.z, false, false, false, true)
    SetEntityHeading(ped, Config.SpawnCoords.w)

    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, true)
    SetPlayerInvincible(PlayerId(), false)

    ClearPedDecorations(ped)
    SetPedDefaultComponentVariation(ped)
    SetFollowPedCamViewMode(1)
end

Citizen.CreateThread(function()
    while true do
        if frozen then
            DisableAllControlActions(0)
        end
        Citizen.Wait(0)
    end
end)
