#!/bin/bash

# ====================================
# SCRIPT DE DÉMARRAGE FRONTEND LIFEHUB
# ====================================

set -e  # Arrêt en cas d'erreur

echo "🌐 Démarrage du frontend LifeHub avec nginx SSL..."
echo "=================================================="

# Configuration
FRONTEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSL_DIR="$FRONTEND_DIR/volumes/ssl"
LOGS_DIR="$FRONTEND_DIR/volumes/logs"

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt du frontend..."
    docker-compose down
    echo "✅ Frontend arrêté"
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

echo "📋 Vérification de l'environnement..."

# Créer les répertoires nécessaires
mkdir -p "$SSL_DIR" "$LOGS_DIR"

# Vérifier le fichier .env
if [ ! -f "../.env-files/frontend.env" ]; then
    echo "⚠️  Fichier .env frontend introuvable, création..."
    mkdir -p "../.env-files"
    cat > "../.env-files/frontend.env" << 'EOF'
VITE_API_URL=http://localhost:8000/api
NODE_ENV=production
VITE_APP_NAME=LifeHub Smart Organizer
EOF
    echo "✅ Fichier frontend.env créé"
fi

# Générer certificats SSL si nécessaire
if [ ! -f "$SSL_DIR/lifehub.crt" ] || [ ! -f "$SSL_DIR/lifehub.key" ]; then
    echo "🔐 Génération des certificats SSL..."
    
    # Générer la clé privée
    openssl genrsa -out "$SSL_DIR/lifehub.key" 2048
    
    # Générer le certificat
    openssl req -new -x509 -key "$SSL_DIR/lifehub.key" -out "$SSL_DIR/lifehub.crt" -days 365 \
        -subj "/C=FR/ST=IDF/L=Paris/O=LifeHub/OU=Frontend/CN=localhost/emailAddress=dev@lifehub.local" \
        -addext "subjectAltName=DNS:localhost,DNS:lifehub.local,DNS:*.lifehub.local,IP:127.0.0.1"
    
    # Permissions
    chmod 600 "$SSL_DIR/lifehub.key"
    chmod 644 "$SSL_DIR/lifehub.crt"
    
    echo "✅ Certificats SSL générés"
else
    echo "✅ Certificats SSL existants trouvés"
fi

# Vérifier si le build existe
if [ ! -d "dist" ]; then
    echo "📦 Build du frontend manquant, construction..."
    if [ -f "package.json" ]; then
        npm install
        npm run build
        echo "✅ Build terminé"
    else
        echo "❌ package.json introuvable"
        exit 1
    fi
else
    echo "✅ Build frontend trouvé"
fi

echo ""
echo "🚀 Démarrage du conteneur frontend..."

# Construire et démarrer
docker-compose up --build -d

echo ""
echo "⏳ Attente du démarrage de nginx..."
sleep 10

# Vérifier le démarrage
echo "🔍 Vérification du frontend..."
max_attempts=15
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -k -s https://localhost/nginx-health > /dev/null; then
        echo "✅ Frontend nginx disponible"
        break
    fi
    echo "⏳ Tentative $attempt/$max_attempts..."
    sleep 2
    ((attempt++))
done

if [ $attempt -gt $max_attempts ]; then
    echo "❌ Frontend non accessible après $max_attempts tentatives"
    echo ""
    echo "📋 Logs du conteneur:"
    docker-compose logs frontend
    exit 1
fi

echo ""
echo "🎉 Frontend démarré avec succès !"
echo "=================================="
echo ""
echo "📍 Services disponibles :"
echo "   🌐 Frontend HTTPS  : https://localhost"
echo "   🔒 Redirection HTTP : http://localhost → https://localhost"
echo "   🏥 Health check    : https://localhost/nginx-health"
echo ""
echo "📁 Fichiers admin accessibles :"
echo "   📄 Configuration   : $(realpath ../.env-files/frontend.env)"
echo "   📂 Logs nginx      : $(realpath volumes/logs/)"
echo "   🔐 Certificats SSL : $(realpath volumes/ssl/)"
echo ""
echo "📋 Commandes utiles :"
echo "   docker-compose logs -f    # Logs en temps réel"
echo "   docker-compose restart    # Redémarrer"
echo "   docker-compose down       # Arrêter"
echo ""
echo "⚠️  Appuyez sur Ctrl+C pour arrêter le frontend"
echo ""

# Suivre les logs
echo "📊 Logs en temps réel (Ctrl+C pour arrêter) :"
docker-compose logs -f 