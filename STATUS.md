# STATUS - FiveM RPG Server

## Ultima actualizare: 2026-06-21

## Unde am rămas
**Faza curentă:** Phase 3 - NUI Login/Register (NEÎNCEPUT)
**Ce urmează:** html/index.html, style.css, script.js - interfața de login/register.

---

## Progres pe Phase-uri

| # | Phase | Status | Detalii |
|---|-------|--------|---------|
| 0 | Repository Init & Scaffolding | ✅ COMPLET | .gitignore, git init, GitHub repo, primul commit |
| 1 | Structura Resurselor FiveM | ✅ COMPLET | fxmanifest.lua, config.lua, server.cfg.example, structura directoare |
| 2 | Database Setup | ✅ COMPLET | sql/init.sql schema, server/db.lua wrapper oxmysql |
| 3 | NUI - Interfața Login/Register | ⏳ NEÎNCEPUT | html/index.html, style.css, script.js - popup obligatoriu |
| 4 | Sistem Autentificare (Server-Side) | ⏳ NEÎNCEPUT | server/auth.lua, server/main.lua - bcrypt, NUI callbacks |
| 5 | Client-Side - Camera & NUI Control | ⏳ NEÎNCEPUT | client/main.lua, spawn.lua - camera cinematică, fără ped, NUI focus |
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
