DB = {}

function DB.GetUserByLicense(license)
    return MySQL.query.await('SELECT * FROM users WHERE license = ?', { license })
end

function DB.GetUserByUsername(username)
    return MySQL.query.await('SELECT * FROM users WHERE username = ?', { username })
end

function DB.IsUsernameTaken(username)
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM users WHERE username = ?', { username })
    return count > 0
end

function DB.CreateUser(license, username, passwordHash, email, fivemName)
    return MySQL.insert.await(
        'INSERT INTO users (license, username, password_hash, email, fivem_name) VALUES (?, ?, ?, ?, ?)',
        { license, username, passwordHash, email, fivemName }
    )
end

function DB.UpdateLoginSuccess(license)
    MySQL.update.await(
        'UPDATE users SET last_login = NOW(), login_attempts = 0 WHERE license = ?',
        { license }
    )
end

function DB.IncrementLoginAttempts(license)
    MySQL.update.await(
        'UPDATE users SET login_attempts = login_attempts + 1 WHERE license = ?',
        { license }
    )
end

function DB.GetLoginAttempts(license)
    return MySQL.scalar.await('SELECT login_attempts FROM users WHERE license = ?', { license }) or 0
end

function DB.IsLicenseRegistered(license)
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM users WHERE license = ?', { license })
    return count > 0
end

function DB.IsBanned(license)
    local banned = MySQL.scalar.await('SELECT is_banned FROM users WHERE license = ?', { license })
    return banned == 1
end
