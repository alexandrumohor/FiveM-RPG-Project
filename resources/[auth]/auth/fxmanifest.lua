fx_version 'cerulean'
game 'gta5'

name 'auth'
description 'Sistem de autentificare RPG cu NUI'
author 'alexandrumohor'
version '1.0.0'

lua54 'yes'

dependencies {
    'oxmysql',
    'bcrypt',
}

shared_scripts {
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/db.lua',
    'server/auth.lua',
    'server/main.lua',
}

client_scripts {
    'client/spawn.lua',
    'client/main.lua',
    'client/nametag.lua',
    'client/chat.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}
