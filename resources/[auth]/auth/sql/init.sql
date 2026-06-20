CREATE TABLE IF NOT EXISTS `users` (
    `id`              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `license`         VARCHAR(100) NOT NULL UNIQUE,
    `username`        VARCHAR(50) NOT NULL UNIQUE,
    `password_hash`   VARCHAR(255) NOT NULL,
    `email`           VARCHAR(255) DEFAULT NULL,
    `fivem_name`      VARCHAR(50) NOT NULL,
    `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_login`      DATETIME DEFAULT NULL,
    `login_attempts`  INT UNSIGNED NOT NULL DEFAULT 0,
    `is_banned`       TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
