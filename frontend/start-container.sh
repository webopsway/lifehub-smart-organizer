#!/bin/bash

# =======================================================
# SCRIPT DE DÉMARRAGE INTELLIGENT CONTENEUR FRONTEND
# =======================================================

set -e

echo "🌐 Démarrage du conteneur frontend LifeHub..."
echo "=============================================="

# Configuration
MODE=${NODE_ENV:-development}
FRONTEND_PORT=${PORT:-3000}
SSL_DIR="/etc/nginx/ssl"

echo "📋 Mode: $MODE"
echo "📋 Port: $FRONTEND_PORT"

# Fonction de génération SSL
generate_ssl() {
    echo "🔐 Génération des certificats SSL..."
    
    if [ ! -f "$SSL_DIR/lifehub.crt" ] || [ ! -f "$SSL_DIR/lifehub.key" ]; then
        openssl genrsa -out "$SSL_DIR/lifehub.key" 2048
        openssl req -new -x509 -key "$SSL_DIR/lifehub.key" -out "$SSL_DIR/lifehub.crt" -days 365 \
            -subj "/C=FR/ST=IDF/L=Paris/O=LifeHub/OU=Frontend/CN=localhost/emailAddress=dev@lifehub.local" \
            -addext "subjectAltName=DNS:localhost,DNS:lifehub.local,DNS:*.lifehub.local,IP:127.0.0.1"
        
        echo "✅ Certificats SSL générés"
    else
        echo "✅ Certificats SSL existants"
    fi
}

# Fonction pour démarrer en mode développement
start_development() {
    echo "🚀 Mode Développement - React Dev Server"
    echo "========================================"
    
    # Installer/mettre à jour les dépendances si nécessaire
    if [ ! -d "node_modules" ] || [ ! -f "node_modules/.installed" ]; then
        echo "📦 Installation des dépendances..."
        npm install
        touch node_modules/.installed
    fi
    
    echo ""
    echo "🎯 Services disponibles en mode DEV :"
    echo "   🔧 React Dev Server : http://localhost:$FRONTEND_PORT"
    echo "   🔄 Hot Reload       : Activé"
    echo "   🐛 DevTools         : Disponibles"
    echo ""
    
    # Démarrer le serveur de développement React
    exec npm run dev -- --host 0.0.0.0 --port $FRONTEND_PORT
}

# Fonction pour démarrer en mode production
start_production() {
    echo "🚀 Mode Production - nginx + React Build"
    echo "========================================"
    
    # Générer les certificats SSL
    generate_ssl
    
    # Build de l'application si nécessaire
    if [ ! -d "dist" ] || [ ! -f "dist/index.html" ]; then
        echo "📦 Build de l'application React..."
        npm run build
    else
        echo "✅ Build React existant trouvé"
    fi
    
    # Copier les fichiers buildés vers nginx
    cp -r dist/* /var/www/html/
    
    echo ""
    echo "🎯 Services disponibles en mode PROD :"
    echo "   🌐 Frontend HTTPS   : https://localhost"
    echo "   🔒 Redirection HTTP : http://localhost → https://localhost"
    echo "   🏥 Health Check     : https://localhost/nginx-health"
    echo ""
    
    # Démarrer nginx en arrière-plan
    nginx -g "daemon off;" &
    NGINX_PID=$!
    
    # Fonction de nettoyage
    cleanup() {
        echo ""
        echo "🛑 Arrêt du conteneur frontend..."
        kill $NGINX_PID 2>/dev/null || true
        exit 0
    }
    
    # Capturer les signaux
    trap cleanup SIGTERM SIGINT
    
    # Attendre nginx
    wait $NGINX_PID
}

# Fonction pour démarrer en mode hybride (dev + nginx)
start_hybrid() {
    echo "🚀 Mode Hybride - React Dev + nginx SSL"
    echo "======================================"
    
    # Générer SSL
    generate_ssl
    
    # Build initial
    npm run build
    cp -r dist/* /var/www/html/
    
    # Démarrer nginx en arrière-plan
    nginx -g "daemon off;" &
    NGINX_PID=$!
    
    # Démarrer le dev server en arrière-plan
    npm run dev -- --host 0.0.0.0 --port $FRONTEND_PORT &
    DEV_PID=$!
    
    echo ""
    echo "🎯 Services disponibles en mode HYBRIDE :"
    echo "   🔧 React Dev Server : http://localhost:$FRONTEND_PORT (hot reload)"
    echo "   🌐 Frontend HTTPS   : https://localhost (nginx SSL)"
    echo "   🔄 Hot Reload       : http://localhost:$FRONTEND_PORT"
    echo ""
    
    # Fonction de nettoyage
    cleanup() {
        echo ""
        echo "🛑 Arrêt du conteneur frontend hybride..."
        kill $NGINX_PID 2>/dev/null || true
        kill $DEV_PID 2>/dev/null || true
        exit 0
    }
    
    # Capturer les signaux
    trap cleanup SIGTERM SIGINT
    
    # Attendre les processus
    wait
}

# Démarrage selon le mode
case "$MODE" in
    "development")
        start_development
        ;;
    "production")
        start_production
        ;;
    "hybrid")
        start_hybrid
        ;;
    *)
        echo "❌ Mode invalide: $MODE"
        echo "Modes disponibles: development, production, hybrid"
        exit 1
        ;;
esac 