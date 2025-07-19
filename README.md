# 🏠 LifeHub Smart Organizer

Une application complète de gestion personnelle avec **frontend nginx SSL** et **backend API FastAPI** séparés.

## 📋 Vue d'ensemble

LifeHub Smart Organizer est votre compagnon numérique pour organiser votre vie quotidienne. Il combine :
- **Gestion de tâches** avec priorités et dates d'échéance
- **Liste de courses** intelligente avec catégories
- **Suivi budgétaire** avec aperçu en temps réel
- **Interface moderne** responsive et intuitive
- **🔐 Frontend sécurisé SSL** via nginx

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Navigateur    │────▶│  Frontend nginx  │────▶│   API FastAPI   │
│   (HTTPS:443)   │     │     (SSL)        │ AJAX│  (HTTP:8000)    │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               │                           │
                               ▼                           ▼
                        ┌──────────────────┐     ┌─────────────────┐
                        │   React Build    │     │ MySQL + Redis   │
                        │   (Static)       │     │   (Docker)      │
                        └──────────────────┘     └─────────────────┘
```

### Structure des fichiers
```
lifehub-smart-organizer/
├── src/                    # Frontend React + TypeScript
├── dist/                   # Build frontend (généré)
├── nginx/                  # Configuration nginx SSL pour frontend
│   ├── nginx.conf         # Config nginx
│   └── ssl/               # Certificats SSL auto-générés
├── backend/               # API FastAPI
│   ├── app/               # Code de l'application
│   ├── venv/              # Environnement virtuel Python
│   └── requirements.txt   # Dépendances Python
├── docker-compose.yml     # Frontend nginx SSL
└── start.sh               # 🚀 Script de démarrage complet
```

## 🚀 Démarrage rapide

### Option 1: Script automatique (Recommandé)

```bash
# Démarrage complet : frontend SSL + backend API
./start.sh
```

**Résultat :**
- ✅ **Frontend** : https://localhost (nginx SSL)
- ✅ **API** : http://localhost:8000 (FastAPI)
- ✅ **Base de données** : MySQL + Redis (Docker)

### Option 2: Manuel étape par étape

```bash
# 1. Frontend avec SSL
npm install && npm run build
./generate-ssl.sh
docker-compose up -d

# 2. Backend API
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python run.py
```

### Option 3: Développement frontend uniquement

```bash
# Mode développement sans SSL (hot reload)
npm install
npm run dev  # http://localhost:5173
```

## 🔐 SSL et Sécurité

### Frontend sécurisé
- **Nginx SSL** avec certificats auto-signés
- **Redirection HTTP → HTTPS** automatique
- **Headers de sécurité** (HSTS, XSS Protection, etc.)
- **Compression Gzip** pour les performances

### API backend
- **CORS configuré** pour accepter le frontend HTTPS
- **Authentification JWT** sécurisée
- **Validation des données** avec Pydantic

### URLs disponibles
- 🌐 **Frontend** : https://localhost
- 🔗 **API** : http://localhost:8000
- 📚 **Documentation** : http://localhost:8000/docs
- 🔒 **Redirection** : http://localhost → https://localhost

## 📱 Fonctionnalités

### ✅ Gestion de tâches
- Création, modification, suppression
- Priorités (Faible, Normal, Urgent)
- Dates d'échéance et statuts
- Interface intuitive

### 🛒 Liste de courses
- Organisation par catégories
- Quantités et prix estimés/réels
- Statistiques d'achat

### 💰 Gestion budgétaire
- Catégories personnalisables
- Suivi mensuel des dépenses
- Alertes de dépassement
- Aperçu global en temps réel

### 🔐 Authentification
- Inscription/connexion JWT
- Gestion de profil
- Sessions sécurisées

## 🛠️ Technologies

### Frontend
- **React 18** + **TypeScript**
- **Vite** pour le build
- **Tailwind CSS** + **shadcn/ui**
- **TanStack Query** pour l'état
- **Nginx** pour SSL

### Backend
- **FastAPI** (Python)
- **SQLAlchemy** + **MySQL**
- **JWT** authentification
- **Pydantic** validation
- **Alembic** migrations

### Infrastructure
- **Docker** pour les services
- **MySQL 8.0** + **Redis**
- **SSL/HTTPS** natif

## 🔧 Configuration

### Variables d'environnement

**Frontend** (`.env.local`)
```env
# API backend
VITE_API_URL=http://localhost:8000/api
```

**Backend** (`backend/.env`)
```env
# Base de données
MYSQL_HOST=localhost
MYSQL_USER=lifehub_user
MYSQL_PASSWORD=lifehub_password
MYSQL_DATABASE=lifehub_db

# Sécurité
SECRET_KEY=your-secret-key
FRONTEND_URL=https://localhost
```

## 🧪 Tests et développement

```bash
# Tests backend
cd backend && source venv/bin/activate && pytest

# Tests frontend
npm run test

# Linting
npm run lint

# Développement avec hot reload
npm run dev  # Frontend sur :5173
# + backend/python run.py  # API sur :8000
```

## 📚 Documentation

### API
- **Swagger UI** : http://localhost:8000/docs
- **ReDoc** : http://localhost:8000/redoc

### Guides
- **Configuration SSL** : [GUIDE_SSL.md](./GUIDE_SSL.md)
- **Hosts locaux** : [nginx/dev-hosts.md](./nginx/dev-hosts.md)

## 🔍 Monitoring

```bash
# Logs frontend nginx
docker-compose logs -f frontend

# Logs backend API (si configuré)
tail -f backend/api.log

# Health checks
curl -k https://localhost/nginx-health  # Frontend
curl http://localhost:8000/health       # API
```

## 🆘 Dépannage

### Frontend SSL
```bash
# Régénérer certificats
./generate-ssl.sh
docker-compose restart frontend

# Vérifier nginx
docker-compose logs frontend
```

### Backend API
```bash
# Vérifier l'environnement
cd backend && source venv/bin/activate
python run.py  # Démarrage manuel

# Tester l'API
curl http://localhost:8000/health
```

### Base de données
```bash
# Redémarrer MySQL
docker restart lifehub_mysql

# Logs MySQL
docker logs lifehub_mysql
```

## 🚀 Déploiement

### Développement
```bash
./start.sh  # Tout-en-un
```

### Production
- **Frontend** : Build static + CDN/nginx avec vrais certificats
- **Backend** : Gunicorn + reverse proxy
- **Base de données** : MySQL managé
- **SSL** : Let's Encrypt ou certificats valides

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature
3. Commit les changements
4. Push et créer une Pull Request

## 📄 Licence

Projet sous licence MIT.

## 🆘 Support

- **Issues** : GitHub Issues
- **Documentation** : Guides dans le projet
- **SSL** : [GUIDE_SSL.md](./GUIDE_SSL.md)

---

**🔐 Frontend sécurisé + API robuste = Productivité maximale !**
