#!/bin/bash

# 🚀 Script de démarrage rapide pour LifeHub Smart Organizer
# Ce script lance automatiquement le backend et le frontend

echo "🏠 LifeHub Smart Organizer - Démarrage automatique"
echo "=================================================="

# Vérification des prérequis
echo "📋 Vérification des prérequis..."

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier Node.js
if ! command -v npm &> /dev/null; then
    echo "❌ Node.js/npm n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

echo "✅ Tous les prérequis sont satisfaits !"

# Fonction pour nettoyer à l'arrêt
cleanup() {
    echo ""
    echo "🛑 Arrêt en cours..."
    cd backend && docker-compose down
    echo "✅ Services arrêtés avec succès"
    exit 0
}

# Capturer Ctrl+C pour nettoyer proprement
trap cleanup INT

echo ""
echo "🐳 Démarrage du backend (MySQL + Redis + API)..."
cd backend

# Copier le fichier d'environnement si nécessaire
if [ ! -f .env ]; then
    echo "📄 Création du fichier .env..."
    cat > .env << EOL
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_USER=lifehub_user
MYSQL_PASSWORD=lifehub_password
MYSQL_DATABASE=lifehub_db
SECRET_KEY=your-super-secret-key-change-in-production-please
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
FRONTEND_URL=http://localhost:5173
REDIS_URL=redis://redis:6379/0
EOL
    echo "✅ Fichier .env créé avec les valeurs par défaut"
fi

# Démarrer les services Docker
docker-compose up -d

echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifier que l'API est accessible
echo "🔍 Vérification de l'API..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:8000/health > /dev/null; then
        echo "✅ API disponible sur http://localhost:8000"
        break
    fi
    echo "⏳ Tentative $attempt/$max_attempts - En attente de l'API..."
    sleep 2
    ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ L'API n'est pas accessible après $max_attempts tentatives"
    echo "📋 Logs Docker:"
    docker-compose logs api
    exit 1
fi

echo ""
echo "⚛️  Démarrage du frontend React..."
cd ..

# Installer les dépendances si nécessaire
if [ ! -d node_modules ]; then
    echo "📦 Installation des dépendances npm..."
    npm install
fi

# Créer le fichier d'environnement frontend si nécessaire
if [ ! -f .env.local ]; then
    echo "📄 Création du fichier .env.local..."
    cat > .env.local << EOL
VITE_API_URL=http://localhost:8000/api
EOL
    echo "✅ Fichier .env.local créé"
fi

echo ""
echo "🎉 Démarrage terminé avec succès !"
echo "================================="
echo ""
echo "📍 Services disponibles :"
echo "   🌐 Frontend React    : http://localhost:5173"
echo "   🔗 API FastAPI       : http://localhost:8000"
echo "   📚 Documentation API : http://localhost:8000/docs"
echo "   🗄️  MySQL            : localhost:3306"
echo "   🔴 Redis             : localhost:6379"
echo ""
echo "🔐 Comptes de test :"
echo "   MySQL: lifehub_user / lifehub_password"
echo ""
echo "⚠️  Pour arrêter tous les services, utilisez Ctrl+C"
echo ""

# Démarrer le serveur de développement Vite
npm run dev 