# FiveM RPG Server

Sistem de autentificare RPG pentru FiveM cu NUI (HTML/CSS/JS overlay), bcrypt password hashing si MariaDB.

## Features

- **NUI Auth UI** - Login/Register cu dark theme si glassmorphism, overlay peste joc
- **Camera cinematica** - La connect nu apare caracter, ci o camera panoramica pe harta
- **Bcrypt** - Parole hash-uite cu bcrypt (cost factor 14)
- **MariaDB** - Stocare persistenta cu oxmysql connector
- **Auto-login** - Dupa register, autentificare automata
- **Protectie brute-force** - Kick automat dupa 3 incercari esuate de login
- **Ban system** - Verificare ban la conectare

## Flux utilizator

1. Player se conecteaza la server
2. Harta se incarca dar nu apare niciun caracter
3. Camera cinematica panoramica pe harta
4. NUI popup automat cu formular Register/Login (nu se poate inchide)
5. Register -> auto-login -> NUI dispare -> camera revine -> ped spawn
6. Login -> NUI dispare -> camera revine -> ped spawn
7. La 3 login-uri esuate -> kick automat

## Prerequisites

- [FiveM Server](https://docs.fivem.net/docs/server-manual/setting-up-a-server/) (cfx-server)
- [MariaDB](https://mariadb.org/download/) 10.6+
- [oxmysql](https://github.com/overextended/oxmysql/releases) resource
- [bcrypt](https://github.com/piotrulos/fivem-bcrypt/releases) resource

## Instalare rapida

1. Cloneaza repo-ul in folder-ul serverului:
   ```
   cd /path/to/server/resources
   git clone https://github.com/alexandrumohor/FiveM-RPG-Project.git [auth]/auth
   ```

2. Importa schema DB:
   ```
   mysql -u root -p fivem_rpg < resources/[auth]/auth/sql/init.sql
   ```

3. Adauga in `server.cfg`:
   ```
   set mysql_connection_string "mysql://root:password@localhost:3306/fivem_rpg?charset=utf8mb4"
   ensure oxmysql
   ensure bcrypt
   ensure auth
   ```

4. Porneste serverul

Pentru setup detaliat, vezi [docs/SETUP.md](docs/SETUP.md).

## Structura proiect

```
resources/[auth]/auth/
  fxmanifest.lua          # Manifest resource FiveM
  config.lua              # Configurari (attempts, bcrypt cost, spawn coords)
  server/
    db.lua                # Wrapper oxmysql (query-uri DB)
    auth.lua              # Logica autentificare (bcrypt, sessions)
    main.lua              # Event handlers, player connect/disconnect
  client/
    spawn.lua             # Spawn management (freeze/unfreeze ped)
    main.lua              # Camera, NUI control, NUI callbacks
  html/
    index.html            # Pagina NUI
    style.css             # Styling dark theme
    script.js             # Logica UI, comunicare cu client Lua
  sql/
    init.sql              # Schema tabel users
```

## Configurare

Editezi `config.lua` pentru:

| Parametru | Default | Descriere |
|-----------|---------|-----------|
| `MaxLoginAttempts` | 3 | Incercari login inainte de kick |
| `BcryptCost` | 14 | Cost factor bcrypt (mai mare = mai sigur dar mai lent) |
| `SpawnCoords` | LS Airport | Coordonate spawn dupa autentificare |
| `CameraCoords` | LS Airport | Pozitie camera cinematica |
| `CameraRotation` | Skyline view | Rotatie camera |

## Tehnologii

- **Lua 5.4** - Scripting FiveM (client + server)
- **HTML/CSS/JS** - NUI overlay
- **MariaDB** - Database
- **oxmysql** - MySQL connector pentru FiveM
- **bcrypt** - Password hashing (native C)

## License

MIT
