local cam = nil
local isAuthenticated = false
local authStarted = false

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.CreateThread(function()
            Citizen.Wait(1000)
            SendNUIMessage({ action = 'forceReload' })
        end)
    end
end)

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do
        Citizen.Wait(100)
    end

    exports.spawnmanager:setAutoSpawnCallback(function()
        exports.spawnmanager:spawnPlayer({
            x = Config.SpawnCoords.x,
            y = Config.SpawnCoords.y,
            z = Config.SpawnCoords.z,
            heading = Config.SpawnCoords.w,
            model = 'mp_m_freemode_01',
            skipFade = true,
        }, function()
            if authStarted then return end
            authStarted = true

            Spawn.Freeze()

            cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            SetCamCoord(cam, Config.CameraCoords.x, Config.CameraCoords.y, Config.CameraCoords.z)
            SetCamRot(cam, Config.CameraRotation.x, Config.CameraRotation.y, Config.CameraRotation.z, 2)
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 0, true, true)

            SetNuiFocus(true, true)
            TriggerServerEvent('auth:checkAccount')
        end)
    end)

    exports.spawnmanager:setAutoSpawn(true)
    exports.spawnmanager:forceRespawn()
end)

RegisterNetEvent('auth:accountStatus', function(status)
    if status.hasAccount then
        SendNUIMessage({ action = 'showLogin', username = status.username })
    else
        SendNUIMessage({ action = 'showRegister' })
    end
end)

RegisterNUICallback('login', function(data, cb)
    TriggerServerEvent('auth:attemptLogin', {
        username = data.username,
        password = data.password,
    })
    cb('ok')
end)

RegisterNUICallback('register', function(data, cb)
    TriggerServerEvent('auth:attemptRegister', {
        username = data.username,
        password = data.password,
        confirmPassword = data.confirmPassword,
        email = data.email,
    })
    cb('ok')
end)

RegisterNetEvent('auth:result', function(result)
    if result.success then
        SendNUIMessage({ action = 'hide' })
        SetNuiFocus(false, false)

        isAuthenticated = true

        RenderScriptCams(false, true, 500, true, true)
        if cam then
            DestroyCam(cam, false)
            cam = nil
        end

        Citizen.Wait(500)
        Spawn.Unfreeze()
    else
        SendNUIMessage({ action = 'message', text = result.message, type = 'error' })
    end
end)

function IsPlayerAuthenticated()
    return isAuthenticated
end
