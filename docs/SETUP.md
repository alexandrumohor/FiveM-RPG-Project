# Setup Guide - FiveM RPG Server

Ghid detaliat de instalare si configurare.

## 1. MariaDB

### Instalare

Descarca MariaDB 10.6+ de pe [mariadb.org/download](https://mariadb.org/download/).

La instalare:
- Seteaza parola pentru `root`
- Lasa portul default `3306`
- Bifeaza "Use UTF8 as default server's character set"

### Creare database

Deschide HeidiSQL sau terminal MySQL:

```sql
CREATE DATABASE fivem_rpg CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Import schema

Ruleaza scriptul SQL inclus:

```
mysql -u root -p fivem_rpg < resources/[auth]/auth/sql/init.sql
```

Sau copiaza continutul din `sql/init.sql` in HeidiSQL si executa.

Schema creeaza tabelul `users`:

| Coloana | Tip | Descriere |
|---------|-----|-----------|
| `id` | INT AUTO_INCREMENT | Primary key |
| `license` | VARCHAR(100) UNIQUE | FiveM license identifier |
| `username` | VARCHAR(50) UNIQUE | Numele ales de player |
| `password_hash` | VARCHAR(255) | Hash bcrypt al parolei |
| `email` | VARCHAR(255) | Email (optional) |
| `fivem_name` | VARCHAR(50) | Numele FiveM al playerului |
| `created_at` | DATETIME | Data crearii contului |
| `last_login` | DATETIME | Ultimul login reusit |
| `login_attempts` | INT | Incercari esuate consecutive |
| `is_banned` | TINYINT(1) | 0 = activ, 1 = banat |

## 2. oxmysql

### Instalare

1. Descarca ultima versiune de pe [github.com/overextended/oxmysql/releases](https://github.com/overextended/oxmysql/releases)
2. Extrage in `resources/oxmysql/` (sa existe `resources/oxmysql/fxmanifest.lua`)

### Configurare

In `server.cfg`, adauga connection string-ul INAINTE de `ensure oxmysql`:

```
set mysql_connection_string "mysql://user:password@localhost:3306/fivem_rpg?charset=utf8mb4"
```

Inlocuieste `user` si `password` cu credentialele tale MariaDB.

Format alternativ:
```
set mysql_connection_string "host=localhost;port=3306;database=fivem_rpg;user=root;password=parola"
```

## 3. bcrypt

### Instalare

1. Descarca de pe [github.com/piotrulos/fivem-bcrypt/releases](https://github.com/piotrulos/fivem-bcrypt/releases)
2. Extrage in `resources/bcrypt/` (sa existe `resources/bcrypt/fxmanifest.lua`)

Resursa bcrypt e nativa (C compiled), nu necesita configurare suplimentara.

### Verificare

Dupa ce pornesti serverul, in consola trebuie sa vezi:
```
[bcrypt] bcrypt resource started
```

Daca primesti eroare la start, verifica ca ai versiunea corecta pentru OS-ul tau (Windows/Linux).

## 4. Resursa auth

### Instalare

Copiaza tot continutul din `resources/[auth]/auth/` in serverul tau:

```
server/resources/[auth]/auth/
```

Structura finala in server:
```
server/
  resources/
    oxmysql/
    bcrypt/
    [auth]/
      auth/
        fxmanifest.lua
        config.lua
        server/
        client/
        html/
        sql/
```

### Configurare

Editeaza `config.lua` dupa preferinte:

```lua
Config.MaxLoginAttempts = 3       -- Kick dupa N incercari esuate
Config.BcryptCost = 14            -- Cost factor (12-15 recomandat)
Config.SpawnCoords = vector4(...)  -- Coordonate spawn dupa login
Config.CameraCoords = vector3(...) -- Pozitie camera la auth
Config.CameraRotation = vector3(...)
```

`Config.Messages` contine toate mesajele afisate in NUI. Modifica-le daca vrei alta limba sau alte texte.

## 5. server.cfg

Adauga in `server.cfg` (ordinea conteaza):

```cfg
# Database connection
set mysql_connection_string "mysql://root:password@localhost:3306/fivem_rpg?charset=utf8mb4"

# Dependencies (trebuie incarcate inainte de auth)
ensure oxmysql
ensure bcrypt

# Auth resource
ensure auth
```

Vezi `server.cfg.example` pentru un exemplu complet.

## 6. Pornire si testare

1. Porneste serverul FiveM
2. Verifica in consola ca nu sunt erori la incarcarea resurselor
3. Conecteaza-te cu clientul FiveM
4. Trebuie sa apara camera cinematica + NUI popup
5. Inregistreaza un cont si verifica in HeidiSQL ca apare in tabelul `users`

### Troubleshooting

**NUI nu apare:**
- Verifica ca `ui_page` e setat corect in `fxmanifest.lua`
- Verifica consola browser F8 pentru erori JavaScript

**Eroare MySQL:**
- Verifica connection string-ul in `server.cfg`
- Verifica ca database-ul `fivem_rpg` exista
- Verifica ca tabelul `users` a fost creat (ruleaza `init.sql`)

**Eroare bcrypt:**
- Verifica ca resursa bcrypt e descarcata si `ensure bcrypt` e inainte de `ensure auth`
- Verifica versiunea corecta pentru OS

**Camera nu apare / ped-ul e vizibil:**
- Verifica ca `spawn.lua` e incarcat inaintea `main.lua` in `fxmanifest.lua`
- Verifica `Config.CameraCoords` si `Config.CameraRotation`
