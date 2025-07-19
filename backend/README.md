# LifeHub Backend API

API FastAPI pour l'application LifeHub Smart Organizer avec authentification JWT et base de données MySQL.

## 🚀 Installation et Démarrage

### Prérequis

- Python 3.11+
- MySQL 8.0+
- Redis (optionnel)

### Installation locale

1. **Créer un environnement virtuel**
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows
```

2. **Installer les dépendances**
```bash
pip install -r requirements.txt
```

3. **Configuration**
```bash
cp .env.example .env
# Éditer .env avec vos paramètres
```

4. **Lancer avec Docker (recommandé)**
```bash
docker-compose up -d
```

5. **Ou lancer manuellement**
```bash
# Démarrer MySQL et Redis
python run.py
```

## 🐳 Docker

### Démarrage rapide
```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down
```

### Services disponibles
- **API**: http://localhost:8000
- **MySQL**: localhost:3306
- **Redis**: localhost:6379
- **Documentation**: http://localhost:8000/docs

## 📚 API Documentation

### Endpoints principaux

#### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion

#### Utilisateurs
- `GET /api/users/me` - Profil utilisateur
- `PUT /api/users/me` - Modifier profil

#### Tâches
- `GET /api/tasks` - Liste des tâches
- `POST /api/tasks` - Créer une tâche
- `PUT /api/tasks/{id}` - Modifier une tâche
- `DELETE /api/tasks/{id}` - Supprimer une tâche
- `PATCH /api/tasks/{id}/toggle` - Basculer l'état

#### Courses
- `GET /api/shopping` - Liste des articles
- `POST /api/shopping` - Ajouter un article
- `PATCH /api/shopping/{id}/toggle` - Marquer comme acheté

#### Budget
- `GET /api/budget/categories` - Catégories de budget
- `GET /api/budget/transactions` - Transactions
- `GET /api/budget/overview` - Aperçu global

## 🗄️ Base de données

### Structure
- **users** - Utilisateurs
- **tasks** - Tâches
- **shopping_items** - Articles de courses
- **budget_categories** - Catégories de budget
- **budget_transactions** - Transactions

### Migrations
```bash
# Créer une migration
alembic revision --autogenerate -m "Description"

# Appliquer les migrations
alembic upgrade head
```

## 🔒 Authentification

- **Type**: JWT Bearer Token
- **Durée**: 30 minutes (configurable)
- **Header**: `Authorization: Bearer <token>`

## 🧪 Tests

```bash
# Lancer les tests
pytest

# Avec couverture
pytest --cov=app tests/
```

## 📝 Variables d'environnement

```env
# Base de données
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=lifehub_user
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=lifehub_db

# Sécurité
SECRET_KEY=your-secret-key
ACCESS_TOKEN_EXPIRE_MINUTES=30

# API
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True

# CORS
FRONTEND_URL=http://localhost:5173
```

## 🚀 Déploiement

### Production
1. Modifier les variables d'environnement
2. Utiliser un serveur de production (Gunicorn, Nginx)
3. Configurer SSL/TLS
4. Mettre en place la surveillance

### Docker Production
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  api:
    build: .
    environment:
      DEBUG: false
    # ... autres configurations
```

## 📊 Monitoring

- **Health Check**: `GET /health`
- **Logs**: Configurés avec uvicorn
- **Métriques**: À implémenter avec Prometheus

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature
3. Commit les changements
4. Push vers la branche
5. Créer une Pull Request 