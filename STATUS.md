# STATUS - FiveM RPG Server

## Ultima actualizare: 2026-06-21

## Unde am rămas
**Faza curentă:** Phase 6 - Documentație & Final (NEÎNCEPUT)
**Ce urmează:** README.md, docs/SETUP.md - documentație proiect și setup.

---

## Progres pe Phase-uri

| # | Phase | Status | Detalii |
|---|-------|--------|---------|
| 0 | Repository Init & Scaffolding | ✅ COMPLET | .gitignore, git init, GitHub repo, primul commit |
| 1 | Structura Resurselor FiveM | ✅ COMPLET | fxmanifest.lua, config.lua, server.cfg.example, structura directoare |
| 2 | Database Setup | ✅ COMPLET | sql/init.sql schema, server/db.lua wrapper oxmysql |
| 3 | NUI - Interfața Login/Register | ✅ COMPLET | html/index.html, style.css, script.js - popup obligatoriu |
| 4 | Sistem Autentificare (Server-Side) | ✅ COMPLET | server/auth.lua, server/main.lua - bcrypt, session tracking, events |
| 5 | Client-Side - Camera & NUI Control | ✅ COMPLET | client/main.lua, spawn.lua - camera cinematică, fără ped, NUI focus |
| 6 | Documentație & Final | ⏳ NEÎNCEPUT | README.md, docs/SETUP.md |

---

## Decizii luate
- Database: MariaDB + oxmysql
- Parole: bcrypt (cost 14)
- UI: NUI (HTML/CSS/JS), NU comenzi de chat
- La connect: fără caracter, camera cinematică pe hartă, NUI popup obligatoriu (nu se poate închide)
- Register: username (opțional, default = FiveM name), password, confirm password, email
- Login: username + password
- Kick automat la 3 login-uri eșuate
- GitHub repo: FiveM-RPG-Project
- Commit + push după fiecare phase + actualizare STATUS.md

---

## Log Modificări
- **2026-06-20** — Planificare completă. PLAN.md și STATUS.md create. Implementarea nu a început.
- **2026-06-21** — Phase 0 completă. Git init, .gitignore, GitHub repo creat, primul commit+push.
- **2026-06-21** — Phase 1 completă. fxmanifest.lua, config.lua, server.cfg.example, structura directoare.
- **2026-06-21** — Phase 2 completă. sql/init.sql cu schema users, server/db.lua wrapper oxmysql cu toate funcțiile DB.
- **2026-06-21** — Phase 3 completă. NUI auth UI: index.html, style.css (dark theme, glassmorphism), script.js (login/register forms, tab switch, NUI messaging, ESC blocat, validare client-side).
- **2026-06-21** — Phase 4 completă. server/auth.lua (Auth module: bcrypt hash/verify cu promises, session tracking in-memory, register cu validări+auto-login, login cu verificare license+password+kick la 3 fail-uri). server/main.lua (playerConnecting ban check cu deferrals, RegisterNetEvent auth:attemptRegister/attemptLogin, playerDropped cleanup).
- **2026-06-21** — Phase 5 completă. client/spawn.lua (Spawn module: freeze/unfreeze ped, invizibil+frozen+invincibil pe auth, DisableAllControlActions în loop, spawn la Config.SpawnCoords). client/main.lua (camera cinematică din Config, NUI show automat, RegisterNUICallback login/register → TriggerServerEvent, auth:result handler: hide NUI, destroy cam, Spawn.Unfreeze). fxmanifest.lua: spawn.lua încărcat înaintea main.lua.
