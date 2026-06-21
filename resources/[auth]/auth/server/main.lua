AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    deferrals.update('Se verifică contul...')

    local license = Auth.GetPlayerLicense(src)
    if not license then
        deferrals.done('Nu s-a putut identifica license-ul FiveM.')
        return
    end

    if DB.IsBanned(license) then
        deferrals.done(Config.Messages.Banned)
        return
    end

    deferrals.done()
end)

RegisterNetEvent('auth:attemptRegister', function(data)
    local src = source
    if Auth.IsAuthenticated(src) then return end
    local result = Auth.Register(src, data)
    TriggerClientEvent('auth:result', src, result)
end)

RegisterNetEvent('auth:attemptLogin', function(data)
    local src = source
    if Auth.IsAuthenticated(src) then return end
    local result = Auth.Login(src, data)
    TriggerClientEvent('auth:result', src, result)
end)

AddEventHandler('playerDropped', function()
    Auth.Logout(source)
end)
