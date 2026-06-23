# STATUS - FiveM RPG Server

## Ultima actualizare: 2026-06-23

## Unde am rămas
**Faza curentă:** Post-launch — funcționalități noi
**Ce urmează:** Resetare parolă pe email, îmbunătățiri UI login/register.

---

## Progres pe Phase-uri

| # | Phase | Status | Detalii |
|---|-------|--------|---------|
| 0 | Repository Init & Scaffolding | ✅ COMPLET | .gitignore, git init, GitHub repo, primul commit |
| 1 | Structura Resurselor FiveM | ✅ COMPLET | fxmanifest.lua, config.lua, server.cfg.example, structura directoare |
| 2 | Database Setup | ✅ COMPLET | sql/init.sql schema, server/db.lua wrapper oxmysql |
| 3 | NUI - Interfața Login/Register | ✅ COMPLET | html/index.html, style.css, script.js - popup obligatoriu |
| 4 | Sistem Autentificare (Server-Side) | ✅ COMPLET | server/auth.lua, server/main.lua - bcrypt, session tracking, events |
| 5 | Client-Side - Camera & NUI Control | ✅ COMPLET | client/main.lua, spawn.lua - camera cinematică, NUI focus, spawnmanager |
| 6 | Documentație & Final | ✅ COMPLET | README.md, docs/SETUP.md |

---

## Funcționalități post-launch (adăugate după Phase 6)

| Feature | Status | Detalii |
|---------|--------|---------|
| Server setup complet | ✅ COMPLET | MariaDB (parola root: root123), oxmysql, bcrypt descărcate, server.cfg cu endpoints+license key, cfx-server-data resources (spawnmanager, sessionmanager, etc.) |
| Auto-detect cont la connect | ✅ COMPLET | Server verifică license → arată Login (cu username pre-completat) sau Register automat |
| Username obligatoriu la register | ✅ COMPLET | Nu mai folosim numele CFX. Username ales de player, unic, obligatoriu |
| Validare username | ✅ COMPLET | Doar litere, cifre, underscore, punct. Filtru cuvinte vulgare cu normalizare leetspeak + vocale + litere repetate (client+server) |
| Fix spawn/caracter vizibil | ✅ COMPLET | spawnmanager setAutoSpawnCallback, model mp_m_freemode_01 încărcat explicit în Unfreeze, SetPedDefaultComponentVariation |
| Nametag deasupra capului | ✅ COMPLET | client/nametag.lua — DrawText3D alb, font 0.55, vizibil la 30m, broadcast la toți clienții |
| Chat in-game | ✅ COMPLET | client/chat.lua — T deschide, Enter trimite, Escape închide, stânga sus |
| NUI cache busting | ✅ COMPLET | style.css/script.js încărcate cu ?v=Date.now(), forceReload din Lua la resource start |
| Stilizare chat | ✅ COMPLET | Panel semi-transparent, format [HH:MM] Name: mesaj, font 16.5px, auto-capitalize, nume albe (ca nametag) |
| Chat persistent | ✅ COMPLET | Chatul nu mai face fade, rămâne vizibil permanent, 10 rânduri fixe cu scroll |
| Chat input persistent | ✅ COMPLET | Input-ul rămâne deschis după trimitere mesaj, nu se mai închide la Enter |
| Chat istoric (săgeți) | ✅ COMPLET | Săgeată sus/jos navighează prin mesajele trimise, cache input curent când navighezi |
| Chat T refocus | ✅ COMPLET | T re-focusează input-ul chiar dacă a pierdut focus (click în joc), fără a scrie "t" |
| Fix fișiere Server | ✅ COMPLET | Descoperit că Server/resources/ avea copii vechi ale fișierelor. Sincronizat cu project root |

---

## Decizii luate
- Database: MariaDB + oxmysql (parola root resetată la root123)
- Parole: bcrypt via fivem-bcrypt-async (GetPasswordHash/VerifyPasswordHash)
- UI: NUI (HTML/CSS/JS), NU comenzi de chat
- La connect: auto-detect cont pe license → Login sau Register automat
- Register: username (obligatoriu, unic), parola, confirmare parola, email (opțional)
- Login: "Bine ai revenit, username" + doar parola
- Username: doar litere/cifre/underscore/punct, filtru vulgar cu leetspeak+vocale+repetiții
- Kick automat la 3 login-uri eșuate
- Spawn: spawnmanager cu setAutoSpawnCallback, model explicit mp_m_freemode_01
- Camera third-person: default GTA V (offset standard, nu se schimbă)
- Nametag: alb, DrawText3D, vizibil 30m
- Chat: T deschide/refocus, Enter trimite (input rămâne deschis), Escape închide, persistent (fără fade), săgeți sus/jos pt istoric
- Chat format: [HH:MM] Name: mesaj, auto-capitalize, nume albe ca nametag, font 16.5px, 10 rânduri vizibile
- Server: endpoint_add_tcp/udp 0.0.0.0:30120, sv_master1 "" (fără listare publică)
- Firewall: port 30120 TCP+UDP deschis manual (netsh)
- GitHub repo: FiveM-RPG-Project

---

## De făcut (planned)
- [ ] Resetare parolă pe email
- [ ] Stilizare/redesign UI login/register

---

## Log Modificări
- **2026-06-20** — Planificare completă. PLAN.md și STATUS.md create. Implementarea nu a început.
- **2026-06-21** — Phase 0 completă. Git init, .gitignore, GitHub repo creat, primul commit+push.
- **2026-06-21** — Phase 1 completă. fxmanifest.lua, config.lua, server.cfg.example, structura directoare.
- **2026-06-21** — Phase 2 completă. sql/init.sql cu schema users, server/db.lua wrapper oxmysql cu toate funcțiile DB.
- **2026-06-21** — Phase 3 completă. NUI auth UI: index.html, style.css (dark theme, glassmorphism), script.js (login/register forms, tab switch, NUI messaging, ESC blocat, validare client-side).
- **2026-06-21** — Phase 4 completă. server/auth.lua (Auth module: bcrypt hash/verify cu promises, session tracking in-memory, register cu validări+auto-login, login cu verificare license+password+kick la 3 fail-uri). server/main.lua (playerConnecting ban check cu deferrals, RegisterNetEvent auth:attemptRegister/attemptLogin, playerDropped cleanup).
- **2026-06-21** — Phase 5 completă. client/spawn.lua, client/main.lua — camera, NUI, spawn.
- **2026-06-21** — Phase 6 completă. README.md, docs/SETUP.md.
- **2026-06-21** — Server setup: MariaDB resetat parola, database fivem_rpg creat, schema importată, oxmysql+bcrypt descărcate, server.cfg creat, FXServer extras din server.7z, cfx-server-data resources copiate, firewall port 30120 deschis.
- **2026-06-21** — Auto-detect cont: auth:checkAccount event, server verifică license în DB, client primește status și arată Login sau Register. Username obligatoriu (fără fallback la CFX name).
- **2026-06-21** — Validare username: caractere permise [a-zA-Z0-9_.], filtru cuvinte vulgare cu normalizare leetspeak, colapsare litere repetate, normalizare vocale (client JS + server Lua).
- **2026-06-21** — Bcrypt adaptat: exports.bcrypt:GetPasswordHash/VerifyPasswordHash (fivem-bcrypt-async), DLL-uri copiate din dist/ în bin/.
- **2026-06-21** — Fix spawn: spawnmanager setAutoSpawnCallback + forceRespawn, model mp_m_freemode_01 încărcat explicit în Unfreeze cu RequestModel/SetPlayerModel/SetPedDefaultComponentVariation.
- **2026-06-22** — Nametag: client/nametag.lua — DrawText3D alb deasupra capului, vizibil 30m, broadcast username la toți clienții via auth:playerName event, cleanup la disconnect.
- **2026-06-22** — Chat in-game: client/chat.lua + NUI chat UI — T deschide, Enter trimite, Escape închide, mesaje stânga sus semi-transparent, fade out 10s, server broadcast via chat:sendMessage/receiveMessage.
- **2026-06-22** — NUI cache busting: style.css și script.js se încarcă cu ?v=Date.now() în index.html. Lua trimite forceReload la onClientResourceStart → JS face window.location.href cu timestamp nou. Jucătorii primesc fișiere fresh fără ștergere manuală cache.
- **2026-06-22** — Stilizare chat (IN PROGRESS): redesign complet — panel cu background blur, header cu icon+titlu+hint ESC, mesaje cu timestamp HH:MM, username-uri colorate (15 culori, hash pe nume), animație slide-in, input cu glow border și hint ENTER, limită 50 mesaje, fade out 1.5s. Cod scris dar netestabil — cache FiveM vechi pe client blochează afișarea noului UI. Necesită o singură ștergere cache client.
- **2026-06-23** — Descoperit că Server/resources/ avea copii vechi ale fișierelor (nu era problemă de cache). Sincronizat toate fișierele auth cu project root.
- **2026-06-23** — Fix ESC chat: mutat handler Escape de pe chatInput pe document level, funcționează indiferent de focus. Redus opacitate panel de la 0.82 la 0.55, scos backdrop-filter blur.
- **2026-06-23** — Stilizare chat finalizată: format [HH:MM] Name: mesaj, nume albe (ca nametag-ul 3D), timestamp alb între [], font mărit la 16.5px, auto-capitalize primul caracter.
- **2026-06-23** — Chat persistent: scos fade-out, chatul rămâne vizibil permanent. Height fix 268px (10 rânduri). Scrollbar ascuns când chatul e închis.
- **2026-06-23** — Chat input persistent: Enter trimite mesajul dar nu mai închide chatul. Săgeți sus/jos pentru navigare istoric mesaje (max 50), cu cache input curent.
- **2026-06-23** — Fix T refocus: dacă input-ul pierde focus (click în joc), T re-focusează input-ul via document keydown handler JS, fără a scrie "t".
