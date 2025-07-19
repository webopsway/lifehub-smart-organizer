#!/bin/bash

# 🚀 Script de démarrage pour LifeHub Smart Organizer
# Frontend nginx SSL + Backend API séparés

echo "🏠 LifeHub Smart Organizer - Frontend SSL + Backend API"
echo "======================================================"

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

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier OpenSSL
if ! command -v openssl &> /dev/null; then
    echo "❌ OpenSSL n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

echo "✅ Tous les prérequis sont satisfaits !"

# Fonction pour nettoyer à l'arrêt
cleanup() {
    echo ""
    echo "🛑 Arrêt en cours..."
    
    # Arrêter le frontend nginx
    docker-compose down 2>/dev/null
    
    # Arrêter l'API backend si elle tourne
    if [ ! -z "$API_PID" ]; then
        echo "🔌 Arrêt de l'API backend..."
        kill $API_PID 2>/dev/null
    fi
    
    echo "✅ Services arrêtés avec succès"
    exit 0
}

# Capturer Ctrl+C pour nettoyer proprement
trap cleanup INT

echo ""
echo "📦 Préparation du frontend..."

# Installer les dépendances frontend si nécessaire
if [ ! -d node_modules ]; then
    echo "📦 Installation des dépendances npm..."
    npm install
fi

# Créer le fichier d'environnement frontend pour l'API backend
echo "📄 Configuration frontend pour API backend..."
cat > .env.local << EOL
VITE_API_URL=http://localhost:8000/api
EOL
echo "✅ Frontend configuré pour utiliser l'API sur :8000"

# Build du frontend pour la production
echo "🔨 Construction du frontend..."
npm run build

if [ ! -d "dist" ]; then
    echo "❌ Erreur lors de la construction du frontend"
    exit 1
fi

echo "✅ Frontend construit avec succès"

echo ""
echo "🔐 Configuration SSL pour le frontend..."

# Générer les certificats SSL si nécessaire
if [ ! -f "nginx/ssl/lifehub.crt" ] || [ ! -f "nginx/ssl/lifehub.key" ]; then
    echo "🔐 Génération des certificats SSL..."
    ./generate-ssl.sh
else
    echo "✅ Certificats SSL déjà présents"
fi

echo ""
echo "🌐 Démarrage du frontend nginx SSL..."

# Démarrer le frontend nginx
docker-compose up -d

echo "⏳ Attente du démarrage de nginx..."
sleep 5

# Vérifier que nginx est accessible
echo "🔍 Vérification du frontend nginx..."
max_attempts=15
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -k -s https://localhost/nginx-health > /dev/null; then
        echo "✅ Frontend nginx disponible sur https://localhost"
        break
    fi
    echo "⏳ Tentative $attempt/$max_attempts - En attente de nginx..."
    sleep 2
    ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Nginx frontend n'est pas accessible après $max_attempts tentatives"
    echo "📋 Logs nginx:"
    docker-compose logs frontend
    exit 1
fi

echo ""
echo "🐍 Préparation du backend API..."

cd backend

# Créer un environnement virtuel Python si nécessaire
if [ ! -d "venv" ]; then
    echo "🐍 Création de l'environnement virtuel Python..."
    python3 -m venv venv
fi

# Activer l'environnement virtuel
source venv/bin/activate

# Installer les dépendances Python
if [ ! -f "venv/installed" ]; then
    echo "📦 Installation des dépendances Python..."
    pip install -r requirements.txt
    touch venv/installed
else
    echo "✅ Dépendances Python déjà installées"
fi

# Créer le fichier d'environnement backend si nécessaire
if [ ! -f .env ]; then
    echo "📄 Création du fichier .env backend..."
    cat > .env << EOL
MYSQL_HOST=localhost
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
FRONTEND_URL=https://localhost
REDIS_URL=redis://localhost:6379/0
EOL
    echo "✅ Fichier .env créé"
fi

echo ""
echo "🗄️ Démarrage des services de données..."

# Démarrer MySQL et Redis avec Docker
docker-compose up -d mysql redis 2>/dev/null || {
    echo "📋 Démarrage de MySQL et Redis via Docker..."
    cat > docker-compose-data.yml << EOL
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    container_name: lifehub_mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: lifehub_db
      MYSQL_USER: lifehub_user
      MYSQL_PASSWORD: lifehub_password
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    command: --default-authentication-plugin=mysql_native_password

  redis:
    image: redis:7-alpine
    container_name: lifehub_redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  mysql_data:
  redis_data:
EOL
    docker-compose -f docker-compose-data.yml up -d
}

echo "⏳ Attente du démarrage de MySQL..."
sleep 10

echo ""
echo "🚀 Démarrage de l'API FastAPI..."

# Démarrer l'API en arrière-plan
python run.py &
API_PID=$!

echo "⏳ Attente du démarrage de l'API..."
sleep 5

# Vérifier que l'API est accessible
echo "🔍 Vérification de l'API backend..."
max_attempts=15
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s http://localhost:8000/health > /dev/null; then
        echo "✅ API backend disponible sur http://localhost:8000"
        break
    fi
    echo "⏳ Tentative $attempt/$max_attempts - En attente de l'API..."
    sleep 2
    ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ API backend n'est pas accessible après $max_attempts tentatives"
    echo "📋 Vérifiez les logs de l'API..."
    kill $API_PID 2>/dev/null
    exit 1
fi

cd ..

echo ""
echo "🎉 Démarrage terminé avec succès !"
echo "================================="
echo ""
echo "📍 Services disponibles :"
echo "   🌐 Frontend HTTPS       : https://localhost"
echo "   🔒 Redirection HTTP     : http://localhost → https://localhost"
echo "   🔗 API Backend          : http://localhost:8000"
echo "   📚 Documentation API    : http://localhost:8000/docs"
echo "   🗄️  MySQL              : localhost:3306"
echo "   🔴 Redis               : localhost:6379"
echo ""
echo "🏗️ Architecture :"
echo "   Frontend (nginx SSL) ──HTTPS──▶ Utilisateur"
echo "                         │"
echo "                         └─AJAX──▶ API Backend (FastAPI)"
echo ""
echo "🔐 Informations SSL :"
echo "   📜 Certificat auto-signé pour le frontend uniquement"
echo "   ⚠️  Acceptez l'exception de sécurité dans votre navigateur"
echo ""
echo "🔐 Comptes de test :"
echo "   MySQL: lifehub_user / lifehub_password"
echo ""
echo "📋 Logs utiles :"
echo "   docker-compose logs frontend  # Logs nginx frontend"
echo "   tail -f backend/api.log       # Logs API (si configuré)"
echo ""
echo "⚠️  Pour arrêter tous les services, utilisez Ctrl+C"
echo ""
echo "🚀 Ouvrez https://localhost dans votre navigateur !"

# Garder le script en vie et suivre les logs
echo ""
echo "📊 Suivi des logs (Ctrl+C pour arrêter) :"
echo "Frontend nginx :"
docker-compose logs -f frontend --tail=20 