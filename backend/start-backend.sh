#!/bin/bash

# ====================================
# SCRIPT DE DÉMARRAGE BACKEND LIFEHUB
# ====================================

set -e  # Arrêt en cas d'erreur

echo "🔧 Démarrage du backend LifeHub (API + MySQL + Redis)..."
echo "======================================================="

# Configuration
BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOLUMES_DIR="$BACKEND_DIR/volumes"
CONFIG_DIR="$BACKEND_DIR/config"

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt du backend..."
    docker-compose down
    echo "✅ Backend arrêté"
    exit 0
}

# Capturer Ctrl+C
trap cleanup INT

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé"
    exit 1
fi

echo "📋 Préparation de l'environnement backend..."

# Créer les répertoires de volumes
mkdir -p "$VOLUMES_DIR"/{mysql,redis,logs/{mysql,redis,api},data/uploads}
mkdir -p "$CONFIG_DIR"

# Vérifier le fichier .env backend
if [ ! -f "../.env-files/backend.env" ]; then
    echo "⚠️  Fichier .env backend introuvable, création..."
    mkdir -p "../.env-files"
    cat > "../.env-files/backend.env" << 'EOF'
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_USER=lifehub_user
MYSQL_PASSWORD=lifehub_password
MYSQL_DATABASE=lifehub_db
MYSQL_ROOT_PASSWORD=rootpassword
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_URL=redis://redis:6379/0
SECRET_KEY=lifehub-super-secret-key-change-in-production
API_HOST=0.0.0.0
API_PORT=8000
ENVIRONMENT=production
DEBUG=False
FRONTEND_URL=https://localhost
EOF
    echo "✅ Fichier backend.env créé"
else
    echo "✅ Fichier backend.env trouvé"
fi

# Créer le script d'initialisation MySQL si nécessaire
if [ ! -f "init.sql" ]; then
    echo "📄 Création du script d'initialisation MySQL..."
    cat > "init.sql" << 'EOF'
-- Script d'initialisation pour LifeHub
CREATE DATABASE IF NOT EXISTS lifehub_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur s'il n'existe pas
CREATE USER IF NOT EXISTS 'lifehub_user'@'%' IDENTIFIED BY 'lifehub_password';
GRANT ALL PRIVILEGES ON lifehub_db.* TO 'lifehub_user'@'%';

-- Permissions pour l'admin
CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin_password';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;

USE lifehub_db;

-- Table de test
CREATE TABLE IF NOT EXISTS health_check (
    id INT AUTO_INCREMENT PRIMARY KEY,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO health_check (status) VALUES ('Database initialized');
EOF
    echo "✅ Script init.sql créé"
fi

# Vérifier les fichiers de configuration
if [ ! -f "$CONFIG_DIR/mysql.cnf" ]; then
    echo "❌ Configuration MySQL manquante"
    echo "   Le fichier config/mysql.cnf doit exister"
    exit 1
fi

if [ ! -f "$CONFIG_DIR/redis.conf" ]; then
    echo "❌ Configuration Redis manquante"
    echo "   Le fichier config/redis.conf doit exister"
    exit 1
fi

echo ""
echo "🚀 Démarrage des services backend..."

# Démarrer les services
docker-compose up --build -d

echo ""
echo "⏳ Attente du démarrage des services..."

# Attendre MySQL
echo "🗄️  Attente de MySQL..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if docker-compose exec -T mysql mysqladmin ping -h localhost -u root -prootpassword > /dev/null 2>&1; then
        echo "✅ MySQL disponible"
        break
    fi
    echo "⏳ MySQL - Tentative $attempt/$max_attempts..."
    sleep 3
    ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ MySQL non accessible"
    docker-compose logs mysql
    exit 1
fi

# Attendre Redis
echo "🔴 Attente de Redis..."
max_attempts=20
attempt=1

while [ $attempt -le $max_attempts ]; do
    if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
        echo "✅ Redis disponible"
        break
    fi
    echo "⏳ Redis - Tentative $attempt/$max_attempts..."
    sleep 2
    ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Redis non accessible"
    docker-compose logs redis
    exit 1
fi

# Attendre l'API
echo "🔗 Attente de l'API FastAPI..."
max_attempts=20
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:8000/health > /dev/null; then
        echo "✅ API FastAPI disponible"
        break
    fi
    echo "⏳ API - Tentative $attempt/$max_attempts..."
    sleep 3
    ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ API non accessible"
    docker-compose logs api
    exit 1
fi

echo ""
echo "🎉 Backend démarré avec succès !"
echo "================================"
echo ""
echo "📍 Services disponibles :"
echo "   🔗 API FastAPI     : http://localhost:8000"
echo "   📚 Documentation   : http://localhost:8000/docs"
echo "   🗄️  MySQL          : localhost:3306"
echo "   🔴 Redis           : localhost:6379"
echo ""
echo "📁 Fichiers admin accessibles :"
echo "   📄 Configuration   : $(realpath ../.env-files/backend.env)"
echo "   📂 Logs MySQL      : $(realpath volumes/logs/mysql/)"
echo "   📂 Logs Redis      : $(realpath volumes/logs/redis/)"
echo "   📂 Logs API        : $(realpath volumes/logs/api/)"
echo "   💾 Données MySQL   : $(realpath volumes/mysql/)"
echo "   💾 Données Redis   : $(realpath volumes/redis/)"
echo "   📁 Uploads         : $(realpath volumes/data/uploads/)"
echo ""
echo "🔐 Comptes de base :"
echo "   MySQL root         : root / rootpassword"
echo "   MySQL utilisateur  : lifehub_user / lifehub_password"
echo "   MySQL admin        : admin / admin_password"
echo ""
echo "📋 Commandes utiles :"
echo "   docker-compose logs -f mysql   # Logs MySQL"
echo "   docker-compose logs -f redis   # Logs Redis"
echo "   docker-compose logs -f api     # Logs API"
echo "   docker-compose restart         # Redémarrer tous"
echo "   docker-compose down            # Arrêter tous"
echo ""
echo "🔍 Tests de santé :"
echo "   curl http://localhost:8000/health    # API"
echo "   mysql -h localhost -u lifehub_user -p # MySQL"
echo "   redis-cli -h localhost ping          # Redis"
echo ""
echo "⚠️  Appuyez sur Ctrl+C pour arrêter le backend"
echo ""

# Suivre les logs de tous les services
echo "📊 Logs des services (Ctrl+C pour arrêter) :"
docker-compose logs -f 