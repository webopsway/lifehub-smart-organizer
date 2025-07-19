#!/bin/bash

# ====================================
# SCRIPT DE DÉMARRAGE FRONTEND LIFEHUB
# Architecture conteneurisée avec Node.js
# ====================================

set -e

echo "🌐 Démarrage du frontend LifeHub conteneurisé..."
echo "================================================"

# Configuration
FRONTEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=${NODE_ENV:-development}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [MODE]"
    echo ""
    echo "Modes disponibles:"
    echo "  development  React dev server avec hot reload (port 3000)"
    echo "  production   nginx SSL avec build optimisé (ports 80/443)"
    echo "  hybrid       Les deux : dev server + nginx SSL"
    echo ""
    echo "Variables d'environnement:"
    echo "  NODE_ENV=development|production|hybrid"
    echo "  VITE_API_URL=http://localhost:8000/api"
    echo ""
    echo "Exemples:"
    echo "  $0 development   # Mode développement avec hot reload"
    echo "  $0 production    # Mode production avec SSL"
    echo "  $0 hybrid        # Mode hybride dev + SSL"
}

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt du conteneur frontend..."
    docker-compose down
    echo "✅ Frontend arrêté"
    exit 0
}

# Capturer Ctrl+C
trap cleanup INT

# Traitement des arguments
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

# Définir le mode
if [ -n "$1" ]; then
    MODE="$1"
fi

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé"
    exit 1
fi

echo "📋 Mode sélectionné: $MODE"

# Créer les répertoires nécessaires
mkdir -p volumes/{ssl,logs}

# Vérifier le fichier .env
if [ ! -f "../.env-files/frontend.env" ]; then
    echo "⚠️  Fichier .env frontend introuvable, création..."
    mkdir -p "../.env-files"
    cat > "../.env-files/frontend.env" << 'EOF'
# API Backend
VITE_API_URL=http://localhost:8000/api
VITE_API_TIMEOUT=30000

# Application
VITE_APP_NAME=LifeHub Smart Organizer
NODE_ENV=development

# Features
VITE_ENABLE_DEBUG=true
EOF
    echo "✅ Fichier frontend.env créé"
fi

echo ""
echo "🚀 Démarrage du conteneur frontend en mode $MODE..."

# Définir les variables d'environnement pour docker-compose
export NODE_ENV="$MODE"
export VITE_API_URL=${VITE_API_URL:-http://localhost:8000/api}

# Démarrer le conteneur
docker-compose up --build -d

echo ""
echo "⏳ Attente du démarrage du conteneur..."
sleep 10

# Vérification selon le mode
echo "🔍 Vérification du frontend..."
max_attempts=20
attempt=1

while [ $attempt -le $max_attempts ]; do
    case "$MODE" in
        "development")
            if curl -s http://localhost:3000 > /dev/null; then
                echo "✅ Frontend dev server disponible"
                break
            fi
            ;;
        "production")
            if curl -k -s https://localhost/nginx-health > /dev/null; then
                echo "✅ Frontend nginx SSL disponible"
                break
            fi
            ;;
        "hybrid")
            dev_ok=false
            ssl_ok=false
            
            if curl -s http://localhost:3000 > /dev/null; then
                dev_ok=true
            fi
            
            if curl -k -s https://localhost/nginx-health > /dev/null; then
                ssl_ok=true
            fi
            
            if [ "$dev_ok" = true ] && [ "$ssl_ok" = true ]; then
                echo "✅ Frontend hybrid (dev + SSL) disponible"
                break
            fi
            ;;
    esac
    
    echo "⏳ Tentative $attempt/$max_attempts..."
    sleep 3
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
echo "🎉 Frontend démarré avec succès en mode $MODE !"
echo "================================================="
echo ""

# Affichage selon le mode
case "$MODE" in
    "development")
        echo "🔧 MODE DÉVELOPPEMENT"
        echo "   🌐 React Dev Server : http://localhost:3000"
        echo "   🔄 Hot Reload       : Activé - Modifiez src/ en temps réel"
        echo "   🐛 DevTools React   : Disponibles"
        echo "   📦 npm/yarn         : Disponible dans le conteneur"
        echo ""
        echo "💡 Commandes utiles dans le conteneur:"
        echo "   docker exec -it lifehub_frontend npm install [package]"
        echo "   docker exec -it lifehub_frontend npm run lint"
        echo "   docker exec -it lifehub_frontend bash"
        ;;
        
    "production")
        echo "🌐 MODE PRODUCTION"
        echo "   🔒 Frontend HTTPS   : https://localhost"
        echo "   🔄 Redirection HTTP : http://localhost → https://localhost"
        echo "   🏥 Health Check     : https://localhost/nginx-health"
        echo "   📦 Build React      : Optimisé et minifié"
        ;;
        
    "hybrid")
        echo "🔀 MODE HYBRIDE"
        echo "   🔧 React Dev Server : http://localhost:3000 (développement)"
        echo "   🌐 Frontend HTTPS   : https://localhost (production)"
        echo "   🔄 Hot Reload       : http://localhost:3000"
        echo "   🏥 Health Check     : https://localhost/nginx-health"
        echo ""
        echo "💡 Développez sur :3000, testez SSL sur :443"
        ;;
esac

echo ""
echo "📁 Environnement conteneurisé :"
echo "   🐳 Conteneur        : lifehub_frontend"
echo "   📄 Configuration    : $(realpath ../.env-files/frontend.env)"
echo "   📂 Code source      : $(realpath src/) (monté en temps réel)"
echo "   📂 Logs nginx       : $(realpath volumes/logs/)"
echo "   🔐 Certificats SSL  : $(realpath volumes/ssl/)"
echo ""
echo "📋 Commandes utiles :"
echo "   docker-compose logs -f              # Logs temps réel"
echo "   docker exec -it lifehub_frontend bash  # Shell dans conteneur"
echo "   docker-compose restart              # Redémarrer"
echo "   docker-compose down                 # Arrêter"
echo ""
echo "🔧 Développement dans le conteneur :"
echo "   - Code source synchronisé en temps réel"
echo "   - Node.js, npm, git disponibles"
echo "   - Hot reload activé"
echo "   - Extensions VS Code compatibles"
echo ""
echo "⚠️  Appuyez sur Ctrl+C pour arrêter le frontend"
echo ""

# Suivre les logs
echo "📊 Logs du conteneur (Ctrl+C pour arrêter) :"
docker-compose logs -f frontend 