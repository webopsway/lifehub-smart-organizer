# 🏠 LifeHub Smart Organizer

Une application complète de gestion personnelle avec un frontend React élégant et un backend FastAPI robuste.

## 📋 Vue d'ensemble

LifeHub Smart Organizer est votre compagnon numérique pour organiser votre vie quotidienne. Il combine :
- **Gestion de tâches** avec priorités et dates d'échéance
- **Liste de courses** intelligente avec catégories
- **Suivi budgétaire** avec aperçu en temps réel
- **Interface moderne** responsive et intuitive

## 🏗️ Architecture

```
lifehub-smart-organizer/
├── src/                    # Frontend React + TypeScript
│   ├── components/         # Composants UI réutilisables
│   ├── pages/             # Pages de l'application
│   ├── hooks/             # Hooks personnalisés
│   └── lib/               # Utilitaires et API client
├── backend/               # API FastAPI + MySQL
│   ├── app/               # Code de l'application
│   │   ├── models/        # Modèles SQLAlchemy
│   │   ├── routers/       # Endpoints API
│   │   ├── schemas/       # Schémas Pydantic
│   │   └── auth.py        # Authentification JWT
│   └── docker-compose.yml # Services Docker
└── README.md
```

## 🚀 Démarrage rapide

### Option 1: Docker (Recommandé)

```bash
# Démarrer le backend avec Docker
cd backend
docker-compose up -d

# Dans un autre terminal, démarrer le frontend
cd ../
npm install
npm run dev
```

### Option 2: Installation manuelle

#### Backend (FastAPI + MySQL)
```bash
cd backend

# Installer les dépendances Python
pip install -r requirements.txt

# Configurer la base de données
# Créer un fichier .env basé sur .env.example
cp .env.example .env

# Démarrer MySQL localement
# Puis lancer l'API
python run.py
```

#### Frontend (React + Vite)
```bash
# Installer les dépendances Node.js
npm install

# Démarrer le serveur de développement
npm run dev
```

## 📱 Fonctionnalités principales

### ✅ Gestion de tâches
- Création, modification, suppression de tâches
- Système de priorités (Faible, Normal, Urgent)
- Dates d'échéance et suivi de progression
- Interface drag & drop intuitive

### 🛒 Liste de courses
- Organisation par catégories (Frais, Légumes, Épicerie, etc.)
- Quantités et unités personnalisables
- Prix estimés vs prix réels
- Statistiques de courses

### 💰 Gestion budgétaire
- Catégories de budget personnalisables
- Suivi des dépenses en temps réel
- Alertes de dépassement de budget
- Aperçu mensuel et tendances

### 🔐 Authentification sécurisée
- Inscription et connexion JWT
- Gestion de profil utilisateur
- Sessions sécurisées
- Protection des données personnelles

## 🛠️ Technologies utilisées

### Frontend
- **React 18** + **TypeScript**
- **Vite** pour le build et le dev server
- **Tailwind CSS** pour le styling
- **shadcn/ui** pour les composants
- **TanStack Query** pour la gestion d'état
- **React Router** pour la navigation

### Backend
- **FastAPI** framework Python moderne
- **SQLAlchemy** ORM avec **MySQL**
- **JWT** pour l'authentification
- **Pydantic** pour la validation
- **Alembic** pour les migrations

### Infrastructure
- **Docker** & **Docker Compose**
- **MySQL 8.0** base de données
- **Redis** pour le cache (optionnel)

## 📊 Aperçu de l'interface

L'interface propose :
- **Tableau de bord** avec statistiques en temps réel
- **Design responsive** mobile-first
- **Animations fluides** et micro-interactions
- **Mode sombre/clair** (à venir)
- **Accessibilité** WCAG 2.1

## 🔧 Configuration

### Variables d'environnement

**Backend** (`.env`)
```env
MYSQL_HOST=localhost
MYSQL_USER=lifehub_user
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=lifehub_db
SECRET_KEY=your-secret-key
```

**Frontend** (`.env.local`)
```env
VITE_API_URL=http://localhost:8000/api
```

## 🧪 Tests et qualité

```bash
# Tests backend
cd backend
pytest

# Tests frontend
npm run test

# Linting
npm run lint
```

## 📚 API Documentation

L'API est entièrement documentée avec OpenAPI/Swagger :
- **Documentation interactive** : http://localhost:8000/docs
- **ReDoc** : http://localhost:8000/redoc

## 🚀 Déploiement

### Production
1. **Backend** : Utiliser Gunicorn + Nginx
2. **Frontend** : Build static + CDN
3. **Base de données** : MySQL managé
4. **Monitoring** : Logs + métriques

### Services cloud recommandés
- **Vercel/Netlify** pour le frontend
- **Railway/Heroku** pour le backend
- **PlanetScale/AWS RDS** pour MySQL

## 🤝 Contribution

Les contributions sont les bienvenues !

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/amazing-feature`)
3. Commit les changements (`git commit -m 'Add amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

- **Issues** : [GitHub Issues](https://github.com/user/lifehub-smart-organizer/issues)
- **Documentation** : [Wiki](https://github.com/user/lifehub-smart-organizer/wiki)

---

**Fait avec ❤️ pour améliorer votre productivité quotidienne**
