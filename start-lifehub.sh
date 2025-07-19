#!/bin/bash

# ====================================
# SCRIPT DE DÉMARRAGE GLOBAL LIFEHUB
# ====================================
# Gestion complète : Frontend + Backend séparés

set -e

echo "🏠 LifeHub Smart Organizer - Démarrage Global"
echo "============================================="
echo "Architecture : Frontend nginx SSL + Backend API conteneurisés"
echo ""

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$PROJECT_DIR/frontend"
BACKEND_DIR="$PROJECT_DIR/backend"

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  all        Démarrer frontend + backend (défaut)"
    echo "  frontend   Démarrer uniquement le frontend"
    echo "  backend    Démarrer uniquement le backend"
    echo "  stop       Arrêter tous les services"
    echo "  status     Afficher le statut des services"
    echo "  logs       Voir les logs de tous les services"
    echo "  help       Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 all       # Démarrage complet"
    echo "  $0 frontend  # Frontend uniquement"
    echo "  $0 backend   # Backend uniquement"
    echo "  $0 stop      # Arrêter tout"
}

# Fonction de vérification des prérequis
check_requirements() {
    echo "📋 Vérification des prérequis..."
    
    local errors=0
    
    # Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker n'est pas installé"
        ((errors++))
    fi
    
    # Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose n'est pas installé"
        ((errors++))
    fi
    
    # Node.js (pour le frontend)
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js n'est pas installé"
        ((errors++))
    fi
    
    # OpenSSL (pour SSL)
    if ! command -v openssl &> /dev/null; then
        echo "❌ OpenSSL n'est pas installé"
        ((errors++))
    fi
    
    if [ $errors -gt 0 ]; then
        echo ""
        echo "❌ $errors prérequis manquants. Installation requise."
        exit 1
    fi
    
    echo "✅ Tous les prérequis sont satisfaits"
}

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt des services LifeHub..."
    
    # Arrêter frontend
    if [ -d "$FRONTEND_DIR" ]; then
        echo "🌐 Arrêt du frontend..."
        cd "$FRONTEND_DIR" && docker-compose down 2>/dev/null || true
    fi
    
    # Arrêter backend
    if [ -d "$BACKEND_DIR" ]; then
        echo "🔧 Arrêt du backend..."
        cd "$BACKEND_DIR" && docker-compose down 2>/dev/null || true
    fi
    
    echo "✅ Tous les services arrêtés"
    exit 0
}

# Capturer Ctrl+C
trap cleanup INT

# Fonction de statut des services
check_status() {
    echo "📊 Statut des services LifeHub:"
    echo "==============================="
    
    # Frontend
    echo ""
    echo "🌐 Frontend (nginx SSL):"
    if curl -k -s https://localhost/nginx-health > /dev/null 2>&1; then
        echo "   ✅ Disponible sur https://localhost"
    else
        echo "   ❌ Non accessible"
    fi
    
    # Backend API
    echo ""
    echo "🔗 Backend API:"
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "   ✅ Disponible sur http://localhost:8000"
    else
        echo "   ❌ Non accessible"
    fi
    
    # MySQL
    echo ""
    echo "🗄️ MySQL:"
    if nc -z localhost 3306 2>/dev/null; then
        echo "   ✅ Disponible sur localhost:3306"
    else
        echo "   ❌ Non accessible"
    fi
    
    # Redis
    echo ""
    echo "🔴 Redis:"
    if nc -z localhost 6379 2>/dev/null; then
        echo "   ✅ Disponible sur localhost:6379"
    else
        echo "   ❌ Non accessible"
    fi
    
    echo ""
}

# Fonction pour démarrer le frontend
start_frontend() {
    echo "🌐 Démarrage du frontend..."
    
    if [ ! -d "$FRONTEND_DIR" ]; then
        echo "❌ Dossier frontend introuvable: $FRONTEND_DIR"
        exit 1
    fi
    
    cd "$FRONTEND_DIR"
    
    # Vérifier si le script existe
    if [ -x "start-frontend.sh" ]; then
        echo "🚀 Utilisation du script de démarrage frontend..."
        ./start-frontend.sh &
        FRONTEND_PID=$!
    else
        echo "📦 Démarrage manuel du frontend..."
        docker-compose up --build -d
    fi
    
    cd "$PROJECT_DIR"
}

# Fonction pour démarrer le backend
start_backend() {
    echo "🔧 Démarrage du backend..."
    
    if [ ! -d "$BACKEND_DIR" ]; then
        echo "❌ Dossier backend introuvable: $BACKEND_DIR"
        exit 1
    fi
    
    cd "$BACKEND_DIR"
    
    # Vérifier si le script existe
    if [ -x "start-backend.sh" ]; then
        echo "🚀 Utilisation du script de démarrage backend..."
        ./start-backend.sh &
        BACKEND_PID=$!
    else
        echo "📦 Démarrage manuel du backend..."
        docker-compose up --build -d
    fi
    
    cd "$PROJECT_DIR"
}

# Fonction pour arrêter tous les services
stop_all() {
    echo "🛑 Arrêt de tous les services..."
    
    # Frontend
    if [ -d "$FRONTEND_DIR" ]; then
        echo "🌐 Arrêt du frontend..."
        cd "$FRONTEND_DIR" && docker-compose down
        cd "$PROJECT_DIR"
    fi
    
    # Backend
    if [ -d "$BACKEND_DIR" ]; then
        echo "🔧 Arrêt du backend..."
        cd "$BACKEND_DIR" && docker-compose down
        cd "$PROJECT_DIR"
    fi
    
    echo "✅ Tous les services arrêtés"
}

# Fonction pour voir les logs
show_logs() {
    echo "📊 Logs des services LifeHub:"
    echo "=============================="
    
    # Frontend logs
    if [ -d "$FRONTEND_DIR" ]; then
        echo ""
        echo "🌐 Logs Frontend:"
        cd "$FRONTEND_DIR" && docker-compose logs --tail=20 frontend 2>/dev/null || echo "Frontend non démarré"
        cd "$PROJECT_DIR"
    fi
    
    # Backend logs
    if [ -d "$BACKEND_DIR" ]; then
        echo ""
        echo "🔧 Logs Backend:"
        cd "$BACKEND_DIR" && docker-compose logs --tail=20 2>/dev/null || echo "Backend non démarré"
        cd "$PROJECT_DIR"
    fi
}

# Traitement des arguments
case "${1:-all}" in
    "all")
        check_requirements
        echo ""
        echo "🚀 Démarrage complet de LifeHub..."
        echo "Frontend nginx SSL + Backend API + MySQL + Redis"
        echo ""
        
        start_backend
        sleep 5
        start_frontend
        
        echo ""
        echo "⏳ Attente de la disponibilité des services..."
        sleep 15
        
        check_status
        
        echo ""
        echo "🎉 LifeHub démarré avec succès !"
        echo "================================"
        echo ""
        echo "📍 Services disponibles :"
        echo "   🌐 Frontend HTTPS  : https://localhost"
        echo "   🔗 API Backend     : http://localhost:8000"
        echo "   📚 Documentation   : http://localhost:8000/docs"
        echo "   🗄️  MySQL          : localhost:3306"
        echo "   🔴 Redis           : localhost:6379"
        echo ""
        echo "📁 Fichiers admin :"
        echo "   📄 Config Frontend : $(realpath .env-files/frontend.env)"
        echo "   📄 Config Backend  : $(realpath .env-files/backend.env)"
        echo "   📂 Logs Frontend   : $(realpath frontend/volumes/logs/)"
        echo "   📂 Logs Backend    : $(realpath backend/volumes/logs/)"
        echo "   💾 Données MySQL   : $(realpath backend/volumes/mysql/)"
        echo "   💾 Données Redis   : $(realpath backend/volumes/redis/)"
        echo ""
        echo "⚠️  Utilisez '$0 stop' pour arrêter tous les services"
        echo ""
        
        # Attendre et suivre les logs
        if [ "$2" = "--follow-logs" ]; then
            echo "📊 Suivi des logs (Ctrl+C pour arrêter) :"
            show_logs
        fi
        ;;
        
    "frontend")
        check_requirements
        start_frontend
        echo "✅ Frontend démarré"
        ;;
        
    "backend")
        check_requirements
        start_backend
        echo "✅ Backend démarré"
        ;;
        
    "stop")
        stop_all
        ;;
        
    "status")
        check_status
        ;;
        
    "logs")
        show_logs
        ;;
        
    "help"|"--help"|"-h")
        show_help
        ;;
        
    *)
        echo "❌ Option invalide: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 