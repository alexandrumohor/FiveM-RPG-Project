local cam = nil
local isAuthenticated = false

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    Spawn.Freeze()

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, Config.CameraCoords.x, Config.CameraCoords.y, Config.CameraCoords.z)
    SetCamRot(cam, Config.CameraRotation.x, Config.CameraRotation.y, Config.CameraRotation.z, 2)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'show' })
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

        Spawn.Unfreeze()
    else
        SendNUIMessage({ action = 'message', text = result.message, type = 'error' })
    end
end)

function IsPlayerAuthenticated()
    return isAuthenticated
end
