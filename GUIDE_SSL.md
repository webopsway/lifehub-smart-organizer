# 🔐 Guide SSL Frontend pour LifeHub

Ce guide explique l'architecture SSL de LifeHub avec **nginx SSL pour le frontend** et **API backend séparée**.

## 🏗️ Architecture SSL

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

## 🚀 Démarrage rapide

### Script automatique
```bash
./start.sh
```

### Manuel
```bash
# 1. Build frontend + SSL
npm run build
./generate-ssl.sh
docker-compose up -d

# 2. API backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python run.py
```

## 🌐 Services disponibles

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | https://localhost | Interface utilisateur avec SSL |
| **API** | http://localhost:8000 | Backend FastAPI |
| **Documentation** | http://localhost:8000/docs | Swagger UI |
| **Health Frontend** | https://localhost/nginx-health | Status nginx |
| **Health API** | http://localhost:8000/health | Status API |

## 🔐 Certificats SSL

### Génération automatique
```bash
./generate-ssl.sh
```

Génère :
- **Algorithme** : RSA 2048 bits
- **Validité** : 365 jours
- **Domaines** : localhost, lifehub.local, *.lifehub.local
- **IP** : 127.0.0.1

### Fichiers créés
```
nginx/ssl/
├── lifehub.crt    # Certificat public
└── lifehub.key    # Clé privée
```

### ⚠️ Avertissement navigateur
1. Allez sur https://localhost
2. Cliquez "Avancé" puis "Continuer vers localhost"
3. Acceptez l'exception de sécurité

## 🔧 Configuration

### Nginx SSL (nginx/nginx.conf)
```nginx
server {
    listen 443 ssl http2;
    server_name localhost lifehub.local;
    
    ssl_certificate /etc/nginx/ssl/lifehub.crt;
    ssl_certificate_key /etc/nginx/ssl/lifehub.key;
    
    root /var/www/html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Frontend (.env.local)
```env
# API backend sans SSL
VITE_API_URL=http://localhost:8000/api
```

### Backend CORS (backend/app/main.py)
```python
allow_origins=[
    "https://localhost",        # Frontend SSL
    "https://lifehub.local",    # Domaine local
    "http://localhost:5173",    # Dev server
]
```

## 🛠️ Développement

### Mode complet avec SSL
```bash
./start.sh  # Frontend SSL + Backend API
```

### Mode développement sans SSL
```bash
# Terminal 1 - Backend
cd backend && python run.py

# Terminal 2 - Frontend dev
npm run dev  # http://localhost:5173
```

## 🔍 Dépannage

### Problème : Frontend SSL inaccessible
```bash
# Vérifier nginx
docker-compose logs frontend

# Régénérer certificats
./generate-ssl.sh
docker-compose restart frontend

# Test direct
curl -k https://localhost/nginx-health
```

### Problème : API backend inaccessible
```bash
# Vérifier l'API
curl http://localhost:8000/health

# Logs API
cd backend && python run.py

# Vérifier l'environnement
cd backend && source venv/bin/activate
pip list | grep fastapi
```

### Problème : CORS errors
Vérifiez la configuration CORS dans `backend/app/main.py` :
```python
allow_origins=[
    "https://localhost",  # Doit correspondre à l'URL frontend
]
```

### Problème : Build frontend échoue
```bash
# Nettoyer et rebuild
rm -rf dist node_modules
npm install
npm run build

# Vérifier le dossier dist
ls -la dist/
```

## 📋 Commandes utiles

### Gestion services
```bash
# Frontend nginx
docker-compose up -d frontend     # Démarrer
docker-compose restart frontend   # Redémarrer
docker-compose logs frontend      # Logs

# Backend API
cd backend && python run.py       # Démarrer
pkill -f "python run.py"         # Arrêter

# Base de données
docker-compose up -d mysql redis  # Services data
```

### Tests de connectivité
```bash
# Frontend
curl -k https://localhost/nginx-health
curl -k https://localhost/

# API
curl http://localhost:8000/health
curl http://localhost:8000/api/

# CORS test
curl -H "Origin: https://localhost" \
     -H "Access-Control-Request-Method: GET" \
     -X OPTIONS http://localhost:8000/api/
```

## 🌍 Domaine personnalisé

### Configuration hosts
Éditez `/etc/hosts` (Linux/macOS) ou `C:\Windows\System32\drivers\etc\hosts` (Windows) :
```
127.0.0.1    lifehub.local
```

### Utilisation
- Frontend : https://lifehub.local
- API : http://localhost:8000 (reste inchangé)

## 🚀 Production

### Frontend
1. **Certificats valides** : Let's Encrypt ou certificats SSL réels
2. **CDN** : Distribuer les assets statiques
3. **Nginx optimisé** : Configuration production

### Backend
1. **Reverse proxy** : nginx → API backend
2. **WSGI server** : Gunicorn au lieu d'uvicorn
3. **Base de données** : MySQL managé

### Exemple nginx production
```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /path/to/real/cert.pem;
    ssl_certificate_key /path/to/real/key.pem;
    
    location / {
        root /var/www/lifehub;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://backend-servers;
        proxy_set_header Host $host;
    }
}
```

## 📊 Monitoring

### Métriques importantes
- **Nginx** : Connexions SSL, temps de réponse
- **API** : Latence, erreurs, throughput
- **Base de données** : Connexions, requêtes

### Logs utiles
```bash
# Nginx access/error
docker-compose logs frontend

# API logs (si configuré)
tail -f backend/logs/api.log

# MySQL logs
docker logs lifehub_mysql
```

## ✅ Checklist de vérification

- [ ] Frontend accessible via https://localhost
- [ ] API accessible via http://localhost:8000
- [ ] Pas d'erreurs CORS dans la console
- [ ] Certificats SSL valides (même auto-signés)
- [ ] Base de données connectée
- [ ] Build frontend récent dans `/dist`

---

## 🆘 Support

**Architecture** : Frontend nginx SSL + Backend API séparé  
**SSL** : Uniquement pour le frontend  
**API** : HTTP direct, protégé par CORS  

Cette architecture offre **flexibilité** et **simplicité** pour le développement !

🎉 **Frontend sécurisé + API performante = LifeHub optimal !** 