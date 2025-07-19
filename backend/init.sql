-- Script d'initialisation pour LifeHub
-- Ceci sera exécuté au premier démarrage de MySQL

-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS lifehub_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur si il n'existe pas
CREATE USER IF NOT EXISTS 'lifehub_user'@'%' IDENTIFIED BY 'lifehub_password';

-- Donner tous les privilèges sur la base de données à l'utilisateur
GRANT ALL PRIVILEGES ON lifehub_db.* TO 'lifehub_user'@'%';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Utiliser la base de données
USE lifehub_db;

-- Les tables seront créées automatiquement par SQLAlchemy 