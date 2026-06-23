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

RegisterNetEvent('auth:checkAccount', function()
    local src = source
    local license = Auth.GetPlayerLicense(src)
    if not license then
        TriggerClientEvent('auth:accountStatus', src, { hasAccount = false })
        return
    end
    local users = DB.GetUserByLicense(license)
    if users and #users > 0 then
        TriggerClientEvent('auth:accountStatus', src, { hasAccount = true, username = users[1].username })
    else
        TriggerClientEvent('auth:accountStatus', src, { hasAccount = false })
    end
end)

RegisterNetEvent('auth:attemptRegister', function(data)
    local src = source
    if Auth.IsAuthenticated(src) then return end
    local result = Auth.Register(src, data)
    TriggerClientEvent('auth:result', src, result)
    if result.success then
        TriggerClientEvent('auth:playerName', -1, src, data.username ~= '' and data.username or GetPlayerName(src))
    end
end)

RegisterNetEvent('auth:attemptLogin', function(data)
    local src = source
    if Auth.IsAuthenticated(src) then return end
    local result = Auth.Login(src, data)
    TriggerClientEvent('auth:result', src, result)
    if result.success then
        local session = Auth.Sessions[src]
        if session then
            TriggerClientEvent('auth:playerName', -1, src, session.username)
        end
    end
end)

RegisterNetEvent('auth:requestNames', function()
    local src = source
    for playerId, session in pairs(Auth.Sessions) do
        TriggerClientEvent('auth:playerName', src, playerId, session.username)
    end
end)

RegisterNetEvent('chat:sendMessage', function(message)
    local src = source
    local session = Auth.Sessions[src]
    if not session then return end
    TriggerClientEvent('chat:receiveMessage', -1, session.username, message)
end)

AddEventHandler('playerDropped', function()
    TriggerClientEvent('auth:playerNameRemove', -1, source)
    Auth.Logout(source)
end)
