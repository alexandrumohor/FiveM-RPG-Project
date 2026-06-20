# FiveM RPG Server - Plan de Implementare

## Context
Construim un server FiveM RPG de la zero. Prima fază e baza: database + sistem complet de autentificare/înregistrare cu NUI (HTML/CSS/JS overlay). Proiectul curent conține doar `.luarc.json`, IDE config, și installerele MariaDB/HeidiSQL în `Server/`.

## Decizii tehnice
- **Database**: MariaDB + oxmysql connector
- **Parole**: bcrypt (cost factor 14) via resource dedicat FiveM
- **UI**: NUI (HTML/CSS/JS) - popup obligatoriu, nu comenzi de chat
- **Spawn**: Fără caracter vizibil - camera pe hartă cu NUI overlay
- **GitHub**: repo "FiveM-RPG-Project"

---

## Phase 0: Repository Init & Scaffolding
- `.gitignore` (exclude `.idea/`, `Server/`, binaries)
- `git init`, commit inițial, `gh repo create FiveM-RPG-Project`
- Creez `STATUS.md` cu toate fazele
- **Commit & Push**

## Phase 1: Structura Resurselor FiveM
Toate resursele custom în `resources/[auth]/auth/`:
- `fxmanifest.lua` - manifest cu dependencies (oxmysql, bcrypt), ui_page directive
- `config.lua` - configurări (max login attempts=3, mesaje, bcrypt cost)
- `server.cfg.example` - exemplu configurare server
- Directoare: `server/`, `client/`, `sql/`, `html/`
- **Commit & Push + Update STATUS.md**

## Phase 2: Database Setup
- `sql/init.sql` - schema tabelei `users`:
  - `id`, `license` (FiveM license, UNIQUE), `username` (UNIQUE), `password_hash` (bcrypt), `email`, `fivem_name`, `created_at`, `last_login`, `login_attempts`, `is_banned`
- `server/db.lua` - wrapper DB cu oxmysql:
  - `DB.GetUserByLicense()`, `DB.IsUsernameTaken()`, `DB.CreateUser()`, `DB.UpdateLoginSuccess()`, `DB.IncrementLoginAttempts()`
- **Commit & Push + Update STATUS.md**

## Phase 3: NUI - Interfața de Login/Register
- `html/index.html` - pagina principală NUI
- `html/style.css` - styling modern, dark theme, centrat pe ecran
- `html/script.js` - logica UI, comunicare cu client Lua via fetch/NUI callbacks
- Formularul de **Register**: username (cu placeholder "Leave blank to use FiveM name"), password, confirm password, email
- Formularul de **Login**: username, password
- Toggle între Register și Login (tab-uri sau link)
- NU are buton de close, NU se poate închide cu ESC
- Mesaje de eroare/succes inline
- **Commit & Push + Update STATUS.md**

## Phase 4: Sistem Autentificare (Server-Side)
- `server/auth.lua` - logica core:
  - Session tracking in-memory (`Auth.Sessions`)
  - `Auth.Register()` - validări, bcrypt hash, insert DB, auto-login după register
  - `Auth.Login()` - verificare license, bcrypt verify, kick la 3 fail-uri
  - `Auth.GetPlayerLicense()`, `Auth.IsAuthenticated()`
- `server/main.lua` - NUI callbacks și events:
  - `RegisterNUICallback('register', ...)` - primește datele din formular
  - `RegisterNUICallback('login', ...)` - primește datele din formular
  - Player connect/disconnect handlers
- **Commit & Push + Update STATUS.md**

## Phase 5: Client-Side - Camera & NUI Control
- `client/main.lua` - entry point client:
  - La spawn: NU creează ped-ul / face ped-ul invizibil și frozen
  - Setează camera la o poziție cinematică pe hartă (skyline view)
  - `SetNuiFocus(true, true)` - activează cursor + keyboard pe NUI
  - Deschide NUI-ul automat (SendNUIMessage cu show)
  - La autentificare reușită: închide NUI, restore camera, spawn ped normal
  - `RegisterNUICallback` handlers pentru comunicare cu server
- `client/spawn.lua` - gestionare spawn/despawn caracter:
  - Override la spawn default: freeze/invisible până la auth
  - Post-auth: spawn normal la coordonate default
- **Commit & Push + Update STATUS.md**

## Phase 6: Documentație & Final
- `README.md` - descriere proiect, prerequisites, instalare
- `docs/SETUP.md` - setup detaliat MariaDB, oxmysql, bcrypt
- Final STATUS.md update - toate fazele complete
- **Commit & Push**

---

## Structura finală fișiere
```
resources/[auth]/auth/
  fxmanifest.lua
  config.lua
  server/main.lua, auth.lua, db.lua
  client/main.lua, spawn.lua
  html/index.html, style.css, script.js
  sql/init.sql
.gitignore, STATUS.md, README.md, server.cfg.example, docs/SETUP.md
```

## Flux utilizator
1. Player se conectează la server
2. Se încarcă harta dar NU apare niciun caracter
3. Camera e pe o poziție cinematică (skyline/panoramic)
4. NUI popup apare automat cu formular Register/Login
5. Nu se poate închide NUI-ul (no close button, ESC disabled)
6. Player face Register → auto-login → NUI dispare → camera revine → ped spawn
7. SAU Player face Login → NUI dispare → camera revine → ped spawn
8. La 3 login-uri eșuate → kick automat

## Detalii tehnice importante

### NUI (HTML/CSS/JS Overlay)
- FiveM permite HTML/CSS/JS overlay peste joc via `ui_page` în fxmanifest.lua
- Comunicare Client Lua → NUI: `SendNUIMessage({action = "show", ...})`
- Comunicare NUI → Client Lua: `fetch('https://auth/register', {method: 'POST', body: JSON.stringify(data)})`
- Client Lua prinde cu: `RegisterNUICallback('register', function(data, cb) ... end)`
- Focus cursor/keyboard: `SetNuiFocus(true, true)`

### Camera cinematică (fără caracter)
- Se creează camera cu `CreateCam('DEFAULT_SCRIPTED_CAMERA', true)`
- Se setează poziție și rotație pentru un view panoramic
- `SetCamActive(cam, true)` + `RenderScriptCams(true, false, 0, true, true)`
- Ped-ul e făcut invizibil: `SetEntityVisible(ped, false)` + `FreezeEntityPosition(ped, true)`
- La auth: destroy camera, restore ped, `RenderScriptCams(false, ...)`

### Bcrypt în FiveM
- Resource separat `bcrypt` (nativ C, nu pure Lua)
- `exports.bcrypt:Hash(password, cost, callback)` 
- `exports.bcrypt:Verify(password, hash, callback)`
- Se wrappează cu `promise.new()` + `Citizen.Await()` pentru cod sincron

### oxmysql API
- Import: `@oxmysql/lib/MySQL.lua`
- `MySQL.query.await(sql, params)` - SELECT
- `MySQL.insert.await(sql, params)` - INSERT (returnează ID)
- `MySQL.update.await(sql, params)` - UPDATE
- `MySQL.scalar.await(sql, params)` - returnează o singură valoare
- Toate folosesc prepared statements (parametri cu `?`) = protecție SQL injection

### Schema DB
```sql
CREATE TABLE users (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    license         VARCHAR(100) NOT NULL UNIQUE,
    username        VARCHAR(50) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    email           VARCHAR(255) DEFAULT NULL,
    fivem_name      VARCHAR(50) NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login      DATETIME DEFAULT NULL,
    login_attempts  INT UNSIGNED NOT NULL DEFAULT 0,
    is_banned       TINYINT(1) NOT NULL DEFAULT 0
);
```
