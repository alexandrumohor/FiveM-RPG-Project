Auth = {}
Auth.Sessions = {}
Auth.Attempts = {}

local vulgarWords = {
    'pula','pule','pulei','pulan','pulica',
    'coaie','coae','coaiele',
    'pizda','pizde','pizdei','pizdulica',
    'muie','muist','muista',
    'fut','fute','futu','futui','futut','futi',
    'cacat','kkt',
    'cur','curva','curve',
    'sugipula','sugpula','sugipl','sugpl',
    'mata','mati','matii',
    'plm','mortii','mortilor',
    'sloboz','labagiu','laba','labari',
    'bulangiu','bulangi','poponar','poponari',
    'retardat','retardata','handicapat','handicapata',
    'idiot','idiota','imbecil','imbecila',
    'cretina','cretin',
    'rahat',
}

local function normalizeForFilter(str)
    local s = string.lower(str)
    local leetMap = {['0']='o',['1']='i',['3']='e',['4']='a',['5']='s',['7']='t',['@']='a',['$']='s',['!']='i'}
    s = s:gsub('[013457@$!]', function(c) return leetMap[c] or c end)
    s = s:gsub('(.)%1+', '%1')
    return s
end

local function vowelNormalize(str)
    return str:gsub('[aeiou]', '*')
end

local vulgarVowelNorm = {}
for _, word in ipairs(vulgarWords) do
    vulgarVowelNorm[#vulgarVowelNorm + 1] = vowelNormalize(word)
end

local function containsVulgar(str)
    local normalized = normalizeForFilter(str)
    local normalizedVowel = vowelNormalize(normalized)
    for i, word in ipairs(vulgarWords) do
        if normalized:find(word, 1, true) then
            return true
        end
        if #word >= 4 and normalizedVowel:find(vulgarVowelNorm[i], 1, true) then
            return true
        end
    end
    return false
end

local function BcryptHash(password)
    return exports.bcrypt:GetPasswordHash(password)
end

local function BcryptVerify(password, hash)
    return exports.bcrypt:VerifyPasswordHash(password, hash)
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
        return { success = false, message = 'Username-ul este obligatoriu.' }
    end

    if #username < 3 then
        return { success = false, message = Config.Messages.UsernameTooShort }
    end

    if not username:match('^[a-zA-Z0-9_.]+$') then
        return { success = false, message = 'Username-ul poate contine doar litere, cifre, underscore si punct.' }
    end

    if containsVulgar(username) then
        return { success = false, message = 'Username-ul contine cuvinte nepermise.' }
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

    local hash = BcryptHash(password)
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
