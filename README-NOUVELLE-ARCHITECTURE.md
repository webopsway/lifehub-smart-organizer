# 🏠 LifeHub Smart Organizer - Architecture Conteneurisée

Une application complète de gestion personnelle avec **architecture séparée** : Frontend nginx SSL et Backend API, chacun dans ses propres conteneurs avec volumes montés accessibles à l'admin système.

## 🏗️ **Architecture Conteneurisée**

```
┌─────────────────────┐     ┌─────────────────────┐
│   FRONTEND          │     │      BACKEND        │
│   (Conteneur 1)     │     │   (Conteneur 2)     │
├─────────────────────┤     ├─────────────────────┤
│ • React + nginx     │────▶│ • FastAPI           │
│ • SSL/HTTPS         │     │ • MySQL 8.0         │
│ • Port 80/443       │     │ • Redis             │
│ • Volumes montés    │     │ • Volumes montés    │
└─────────────────────┘     └─────────────────────┘
        │                            │
        ▼                            ▼
┌─────────────────────┐     ┌─────────────────────┐
│ VOLUMES FRONTEND    │     │  VOLUMES BACKEND    │
├─────────────────────┤     ├─────────────────────┤
│ • logs/nginx/       │     │ • volumes/mysql/    │
│ • volumes/ssl/      │     │ • volumes/redis/    │
│ • .env accessible   │     │ • .env accessible   │
└─────────────────────┘     │ • .env accessible   │
                            └─────────────────────┘
```

## 📂 **Structure des Fichiers**

```
lifehub-smart-organizer/
├── frontend/                           # 🌐 CONTENEUR FRONTEND
│   ├── src/                           # Sources React
│   ├── public/                        # Assets publics
│   ├── nginx/                         # Configuration nginx
│   │   └── nginx.conf                 # Config SSL + SPA routing
│   ├── volumes/                       # 📁 VOLUMES MONTÉS
│   │   ├── ssl/                       # Certificats SSL accessibles
│   │   │   ├── lifehub.crt
│   │   │   └── lifehub.key
│   │   └── logs/                      # Logs nginx accessibles
│   │       ├── access.log
│   │       └── error.log
│   ├── Dockerfile                     # Build React + nginx
│   ├── docker-compose.yml             # Frontend seul
│   ├── start-frontend.sh              # Script démarrage frontend
│   └── package.json                   # Dépendances React
│
├── backend/                            # 🔧 CONTENEUR BACKEND  
│   ├── app/                           # Code FastAPI
│   │   ├── models/                    # Modèles SQLAlchemy
│   │   ├── routers/                   # Routes API
│   │   ├── schemas/                   # Schémas Pydantic
│   │   └── config.py                  # Configuration étendue
│   ├── volumes/                       # 📁 VOLUMES MONTÉS
│   │   ├── mysql/                     # 💾 Données MySQL accessibles
│   │   ├── redis/                     # 💾 Données Redis accessibles
│   │   ├── logs/                      # 📋 Logs accessibles
│   │   │   ├── mysql/                 # Logs MySQL
│   │   │   ├── redis/                 # Logs Redis
│   │   │   └── api/                   # Logs API
│   │   └── data/                      # 📁 Données application
│   │       └── uploads/               # Fichiers uploadés
│   ├── config/                        # Configurations services
│   │   ├── mysql.cnf                  # Config MySQL optimisée
│   │   └── redis.conf                 # Config Redis optimisée
│   ├── Dockerfile                     # Build FastAPI
│   ├── docker-compose.yml             # Backend + MySQL + Redis
│   ├── start-backend.sh               # Script démarrage backend
│   └── requirements.txt               # Dépendances Python
│
├── .env-files/                         # 📄 FICHIERS ENV ACCESSIBLES
│   ├── frontend.env                   # Variables frontend
│   └── backend.env                    # Variables backend
│
├── start-lifehub.sh                   # 🚀 SCRIPT GLOBAL
└── README-NOUVELLE-ARCHITECTURE.md    # Cette documentation
```

## 🚀 **Démarrage Rapide**

### Option 1 : Démarrage Complet (Recommandé)
```bash
# Démarrer tous les services
./start-lifehub.sh all

# Résultat :
# ✅ Frontend : https://localhost (nginx SSL)
# ✅ API     : http://localhost:8000 (FastAPI)
# ✅ MySQL   : localhost:3306
# ✅ Redis   : localhost:6379
```

### Option 2 : Services Séparés
```bash
# Frontend uniquement
./start-lifehub.sh frontend

# Backend uniquement  
./start-lifehub.sh backend

# Arrêter tout
./start-lifehub.sh stop

# Statut des services
./start-lifehub.sh status
```

### Option 3 : Scripts Individuels
```bash
# Frontend dans son propre terminal
cd frontend && ./start-frontend.sh

# Backend dans son propre terminal
cd backend && ./start-backend.sh
```

## 📁 **Volumes Montés - Admin Système**

### Frontend - Fichiers Accessibles
```bash
# Configuration
.env-files/frontend.env              # Variables d'environnement

# Logs nginx (temps réel)
frontend/volumes/logs/access.log     # Accès HTTP/HTTPS
frontend/volumes/logs/error.log      # Erreurs nginx

# SSL (modifiable)
frontend/volumes/ssl/lifehub.crt     # Certificat SSL
frontend/volumes/ssl/lifehub.key     # Clé privée SSL
```

### Backend - Fichiers Accessibles
```bash
# Configuration
.env-files/backend.env               # Variables d'environnement

# Données persistantes (sauvegarde possible)
backend/volumes/mysql/               # Base de données MySQL
backend/volumes/redis/               # Cache Redis

# Logs services (surveillance)
backend/volumes/logs/mysql/          # Logs MySQL
backend/volumes/logs/redis/          # Logs Redis  
backend/volumes/logs/api/            # Logs API FastAPI

# Données application
backend/volumes/data/uploads/        # Fichiers uploadés
```

## ⚙️ **Configuration Admin - Fichiers .env**

### Frontend (.env-files/frontend.env)
```env
# API Backend
VITE_API_URL=http://localhost:8000/api
VITE_API_TIMEOUT=30000

# Application
VITE_APP_NAME=LifeHub Smart Organizer
NODE_ENV=production

# Sécurité SSL
VITE_ENABLE_SSL=true

# Performance
VITE_CACHE_TIMEOUT=300000
```

### Backend (.env-files/backend.env)
```env
# Base de données
MYSQL_HOST=mysql
MYSQL_USER=lifehub_user
MYSQL_PASSWORD=lifehub_password
MYSQL_DATABASE=lifehub_db

# Cache Redis
REDIS_HOST=redis
REDIS_URL=redis://redis:6379/0

# Sécurité API
SECRET_KEY=lifehub-super-secret-key-change-in-production
FRONTEND_URL=https://localhost

# Configuration
ENVIRONMENT=production
DEBUG=False
LOG_LEVEL=INFO
```

## 🔐 **SSL et Sécurité**

### Frontend Sécurisé
- **Nginx SSL** avec certificats auto-signés
- **HTTP → HTTPS** automatique
- **Headers sécurité** (HSTS, XSS, etc.)
- **Certificats** dans `frontend/volumes/ssl/`

### Communication Sécurisée
- **Frontend** : HTTPS uniquement
- **API** : HTTP avec CORS configuré
- **Bases** : Réseaux Docker isolés

## 📊 **Monitoring et Administration**

### Commandes de Monitoring
```bash
# Statut global
./start-lifehub.sh status

# Logs en temps réel
./start-lifehub.sh logs

# Logs par service
docker-compose -f frontend/docker-compose.yml logs -f
docker-compose -f backend/docker-compose.yml logs -f mysql
docker-compose -f backend/docker-compose.yml logs -f redis
docker-compose -f backend/docker-compose.yml logs -f api
```

### Health Checks
```bash
# Frontend nginx
curl -k https://localhost/nginx-health

# API Backend
curl http://localhost:8000/health

# MySQL
mysql -h localhost -u lifehub_user -p

# Redis
redis-cli -h localhost ping
```

### Accès Base de Données
```bash
# MySQL (admin système)
mysql -h localhost -u admin -padmin_password

# MySQL (application)
mysql -h localhost -u lifehub_user -plifehub_password lifehub_db

# Redis
redis-cli -h localhost
```

## 🔧 **Maintenance Admin**

### Sauvegarde des Données
```bash
# Sauvegarde MySQL
mysqldump -h localhost -u admin -p lifehub_db > backup_$(date +%Y%m%d).sql

# Sauvegarde Redis
redis-cli -h localhost save
cp backend/volumes/redis/dump.rdb backup_redis_$(date +%Y%m%d).rdb

# Sauvegarde fichiers
tar -czf backup_uploads_$(date +%Y%m%d).tar.gz backend/volumes/data/uploads/
```

### Rotation des Logs
```bash
# Nettoyer logs nginx (auto via logrotate)
ls -la frontend/volumes/logs/

# Nettoyer logs application
find backend/volumes/logs/ -name "*.log" -mtime +30 -delete
```

### Mise à Jour Configuration
```bash
# Modifier frontend
nano .env-files/frontend.env
cd frontend && docker-compose restart

# Modifier backend  
nano .env-files/backend.env
cd backend && docker-compose restart api
```

## 🚀 **Déploiement Production**

### Checklist Production
- [ ] **Certificats SSL** valides (Let's Encrypt)
- [ ] **Mots de passe** sécurisés dans .env
- [ ] **Firewall** configuré (80, 443, 3306, 6379)
- [ ] **Monitoring** activé (logs, métriques)
- [ ] **Sauvegardes** automatisées
- [ ] **Updates** sécurité planifiées

### Services Externes Recommandés
- **SSL** : Let's Encrypt ou certificats payants
- **MySQL** : RDS, PlanetScale, ou managé
- **Redis** : ElastiCache, Redis Cloud
- **Monitoring** : Prometheus + Grafana
- **Logs** : ELK Stack, Fluentd

## 🆘 **Dépannage**

### Problème : Frontend SSL inaccessible
```bash
# Vérifier certificats
ls -la frontend/volumes/ssl/
./frontend/start-frontend.sh

# Régénérer SSL
cd frontend && rm -rf volumes/ssl/* && ./start-frontend.sh
```

### Problème : Backend API erreur
```bash
# Logs détaillés
cd backend && docker-compose logs api

# Vérifier base
docker-compose logs mysql
mysql -h localhost -u lifehub_user -p
```

### Problème : Données perdues
```bash
# Vérifier volumes
ls -la backend/volumes/mysql/
ls -la backend/volumes/redis/

# Restaurer sauvegarde
mysql -h localhost -u admin -p lifehub_db < backup_20231201.sql
```

## 📋 **Avantages de cette Architecture**

### ✅ **Séparation des Responsabilités**
- Frontend nginx SSL indépendant
- Backend API avec services dédiés
- Volumes persistants montés

### ✅ **Administration Facilitée**
- Fichiers .env accessibles sur disque
- Logs centralisés et consultables
- Données persistantes visibles

### ✅ **Scalabilité**
- Services indépendants
- Load balancing possible
- Déploiement modulaire

### ✅ **Maintenance**
- Redémarrage sélectif
- Mise à jour par service
- Sauvegarde granulaire

---

## 🎯 **Cette architecture répond à vos besoins :**

✅ **Application complète** : Frontend + Backend conteneurisés  
✅ **Nginx pour frontend** : SSL + React optimisé  
✅ **Docker Compose séparés** : Un pour frontend, un pour backend  
✅ **Fichiers .env accessibles** : Dans `.env-files/` sur le disque  
✅ **Volumes montés** : MySQL, Redis, logs visibles par l'admin  
✅ **Données accessibles** : Sauvegarde et surveillance simplifiées  

**🚀 Prêt pour production et maintenance par l'admin système !** 