Auth = {}
Auth.Sessions = {}
Auth.Attempts = {}

local function BcryptHash(password, cost)
    local p = promise.new()
    exports.bcrypt:Hash(password, cost, function(hash)
        p:resolve(hash)
    end)
    return Citizen.Await(p)
end

local function BcryptVerify(password, hash)
    local p = promise.new()
    exports.bcrypt:Verify(password, hash, function(matches)
        p:resolve(matches)
    end)
    return Citizen.Await(p)
end

function Auth.GetPlayerLicense(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.find(id, '^license:') then
            return id
        end
    end
    return nil
end

function Auth.IsAuthenticated(source)
    return Auth.Sessions[source] ~= nil
end

function Auth.Register(source, data)
    local license = Auth.GetPlayerLicense(source)
    if not license then
        return { success = false, message = 'Nu s-a putut identifica license-ul.' }
    end

    if DB.IsLicenseRegistered(license) then
        return { success = false, message = Config.Messages.AlreadyRegistered }
    end

    local username = data.username
    local password = data.password
    local confirmPassword = data.confirmPassword
    local email = data.email

    if not username or username == '' then
        username = GetPlayerName(source)
    end

    if #username < 3 then
        return { success = false, message = Config.Messages.UsernameTooShort }
    end

    if not password or #password < 6 then
        return { success = false, message = Config.Messages.PasswordTooShort }
    end

    if password ~= confirmPassword then
        return { success = false, message = Config.Messages.PasswordMismatch }
    end

    if DB.IsUsernameTaken(username) then
        return { success = false, message = Config.Messages.UsernameTaken }
    end

    local hash = BcryptHash(password, Config.BcryptCost)
    local fivemName = GetPlayerName(source)
    DB.CreateUser(license, username, hash, email, fivemName)

    Auth.Sessions[source] = { license = license, username = username }
    DB.UpdateLoginSuccess(license)

    return { success = true, message = Config.Messages.RegisterSuccess }
end

function Auth.Login(source, data)
    local license = Auth.GetPlayerLicense(source)
    if not license then
        return { success = false, message = 'Nu s-a putut identifica license-ul.' }
    end

    if DB.IsBanned(license) then
        DropPlayer(source, Config.Messages.Banned)
        return { success = false, message = Config.Messages.Banned }
    end

    local username = data.username
    local password = data.password

    if not username or username == '' or not password or password == '' then
        return { success = false, message = Config.Messages.LoginFailed }
    end

    local results = DB.GetUserByUsername(username)
    if not results or #results == 0 then
        Auth.HandleFailedAttempt(source)
        return { success = false, message = Config.Messages.LoginFailed }
    end

    local user = results[1]

    if user.license ~= license then
        Auth.HandleFailedAttempt(source)
        return { success = false, message = Config.Messages.LoginFailed }
    end

    local matches = BcryptVerify(password, user.password_hash)
    if not matches then
        Auth.HandleFailedAttempt(source)
        return { success = false, message = Config.Messages.LoginFailed }
    end

    Auth.Sessions[source] = { license = license, username = user.username }
    Auth.Attempts[source] = nil
    DB.UpdateLoginSuccess(license)

    return { success = true, message = Config.Messages.LoginSuccess }
end

function Auth.HandleFailedAttempt(source)
    Auth.Attempts[source] = (Auth.Attempts[source] or 0) + 1
    if Auth.Attempts[source] >= Config.MaxLoginAttempts then
        DropPlayer(source, Config.Messages.TooManyAttempts)
    end
end

function Auth.Logout(source)
    Auth.Sessions[source] = nil
    Auth.Attempts[source] = nil
end
