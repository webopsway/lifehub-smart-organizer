# 🐳 Guide Conteneurs LifeHub - Frontend avec Node.js

## 🎯 **Architecture Conteneurisée Complète**

Le frontend LifeHub est maintenant **entièrement conteneurisé** avec Node.js, npm, et tous les outils de développement embarqués.

### 📦 **Contenu du Conteneur Frontend**
```
🐳 lifehub_frontend
├── 🔧 Node.js 18 + npm
├── 🌐 nginx + OpenSSL  
├── 📂 Code React monté en temps réel
├── 🔄 Hot reload activé
├── 📦 Dépendances installées
└── 🔐 SSL auto-configuré
```

## 🚀 **Modes de Fonctionnement**

### **1. Mode Développement (Recommandé)**
```bash
# Frontend seul en mode dev
./start-lifehub.sh frontend development

# OU frontend + backend
./start-lifehub.sh all development
```

**Résultat :**
- ✅ **React Dev Server** : http://localhost:3000
- ✅ **Hot Reload** : Modifiez `src/` → rechargement automatique
- ✅ **DevTools React** : Extensions browser fonctionnelles
- ✅ **npm/yarn** : Disponible dans le conteneur

### **2. Mode Production**
```bash
# Frontend avec nginx SSL
./start-lifehub.sh frontend production

# OU tout en production
./start-lifehub.sh all production
```

**Résultat :**
- ✅ **Frontend HTTPS** : https://localhost
- ✅ **Build optimisé** : React minifié et compressé
- ✅ **nginx SSL** : Certificats auto-générés
- ✅ **Performance** : Gzip, cache headers

### **3. Mode Hybride**
```bash
# Les deux simultanément !
./start-lifehub.sh frontend hybrid
```

**Résultat :**
- ✅ **Dev Server** : http://localhost:3000 (développement)
- ✅ **nginx SSL** : https://localhost (test production)
- ✅ **Hot Reload** : Sur le port 3000
- ✅ **Test SSL** : Sur le port 443

## 🔧 **Développement dans le Conteneur**

### **Code Source Synchronisé**
```bash
# Modifier le code React
nano frontend/src/App.tsx        # Modifié sur l'host
                                 # ↓ Synchronisé automatiquement
                                 # Rechargement automatique dans le conteneur
```

### **Commandes dans le Conteneur**
```bash
# Shell dans le conteneur
docker exec -it lifehub_frontend bash

# Dans le conteneur, vous avez accès à :
npm install react-router-dom     # Installer packages
npm run lint                     # Linter
npm run test                     # Tests
npm run build                    # Build production
git status                       # Git disponible
```

### **Installation de Packages**
```bash
# Depuis l'host
docker exec -it lifehub_frontend npm install axios

# OU depuis le conteneur
docker exec -it lifehub_frontend bash
> npm install @tanstack/react-query
> npm run dev  # Redémarrer le dev server
```

## 📁 **Volumes et Persistance**

### **Volumes Montés Automatiquement**
```
Host                          →  Conteneur
frontend/src/                 →  /app/src/ (temps réel)
frontend/public/              →  /app/public/
frontend/package.json         →  /app/package.json
frontend/volumes/ssl/         →  /etc/nginx/ssl/
frontend/volumes/logs/        →  /var/log/nginx/
.env-files/frontend.env       →  /app/.env
```

### **Volumes Persistants**
```bash
# Node modules persistants (performance)
docker volume ls | grep frontend_node_modules

# Build React persistant
ls -la frontend/dist/
```

## 🔄 **Workflow de Développement**

### **Démarrage Quotidien**
```bash
# 1. Démarrer en mode development
./start-lifehub.sh all development

# 2. Ouvrir dans le browser
open http://localhost:3000

# 3. Développer
code frontend/src/  # VS Code avec sync automatique
```

### **Tests et Build**
```bash
# Tester en mode production (sans arrêter dev)
./start-lifehub.sh frontend hybrid

# Vérifier https://localhost ET http://localhost:3000

# Build final
docker exec -it lifehub_frontend npm run build
ls -la frontend/dist/
```

### **Debugging**
```bash
# Logs du conteneur
docker logs lifehub_frontend -f

# Shell pour debug
docker exec -it lifehub_frontend bash

# Vérifier les processus
docker exec -it lifehub_frontend ps aux

# Vérifier les ports
docker exec -it lifehub_frontend netstat -tlnp
```

## 🎛️ **Configuration Avancée**

### **Variables d'Environnement**
```bash
# Modifier .env-files/frontend.env
VITE_API_URL=http://localhost:8000/api
VITE_APP_NAME=LifeHub Smart Organizer
NODE_ENV=development
VITE_ENABLE_DEBUG=true

# Redémarrer pour appliquer
docker-compose -f frontend/docker-compose.yml restart
```

### **Modes Personnalisés**
```bash
# Forcer un mode spécifique
export NODE_ENV=hybrid
./start-lifehub.sh frontend

# Avec API backend personnalisée
export VITE_API_URL=http://api.example.com
./start-lifehub.sh frontend development
```

## 🚨 **Dépannage**

### **Conteneur ne démarre pas**
```bash
# Vérifier les logs
docker logs lifehub_frontend

# Rebuild complet
cd frontend && docker-compose build --no-cache

# Nettoyer les volumes
docker volume prune
```

### **Hot Reload ne fonctionne pas**
```bash
# Vérifier les volumes montés
docker exec -it lifehub_frontend ls -la /app/src/

# Redémarrer le conteneur
docker restart lifehub_frontend

# Vérifier le processus Vite
docker exec -it lifehub_frontend ps aux | grep vite
```

### **Port 3000 non accessible**
```bash
# Vérifier que le conteneur expose le port
docker port lifehub_frontend

# Vérifier les processus
docker exec -it lifehub_frontend netstat -tlnp | grep 3000

# Redémarrer en mode development
./start-lifehub.sh frontend development
```

### **SSL ne fonctionne pas**
```bash
# Régénérer les certificats
docker exec -it lifehub_frontend rm -rf /etc/nginx/ssl/*
docker restart lifehub_frontend

# Vérifier nginx
docker exec -it lifehub_frontend nginx -t
```

## 📋 **Commandes Utiles**

### **Gestion des Conteneurs**
```bash
# Statut complet
./start-lifehub.sh status

# Logs temps réel
docker logs lifehub_frontend -f

# Redémarrer
docker restart lifehub_frontend

# Arrêter
./start-lifehub.sh stop
```

### **Développement**
```bash
# Shell interactif
docker exec -it lifehub_frontend bash

# Commandes npm
docker exec -it lifehub_frontend npm run lint
docker exec -it lifehub_frontend npm run test
docker exec -it lifehub_frontend npm run build

# Installer un package
docker exec -it lifehub_frontend npm install [package]
```

### **Monitoring**
```bash
# Ressources utilisées
docker stats lifehub_frontend

# Processus dans le conteneur
docker exec -it lifehub_frontend top

# Espace disque
docker exec -it lifehub_frontend df -h
```

## 🎯 **Avantages de cette Architecture**

### ✅ **Environnement Isolé**
- Node.js, npm, git dans le conteneur
- Pas d'installation locale requise
- Versions contrôlées et reproductibles

### ✅ **Développement Transparent** 
- Code source synchronisé en temps réel
- Hot reload natif
- Extensions VS Code compatibles

### ✅ **Flexibilité**
- 3 modes : development, production, hybrid
- Switch facile entre les modes
- SSL disponible en un clic

### ✅ **Production-Ready**
- nginx optimisé avec SSL
- Build React minifié
- Headers de sécurité configurés

---

**🚀 Avec cette architecture, vous développez comme en local mais dans un environnement parfaitement maîtrisé et conteneurisé !** 