# Frontend complet avec Node.js + nginx
FROM node:18-alpine

# Installer nginx et les outils nécessaires
RUN apk add --no-cache \
    nginx \
    openssl \
    curl \
    bash \
    git

# Variables d'environnement
ENV NODE_ENV=development
ENV PORT=3000
ENV NGINX_PORT=80
ENV NGINX_SSL_PORT=443

# Créer l'utilisateur pour les permissions
RUN addgroup -g 1001 -S appuser && \
    adduser -S -D -H -u 1001 -h /app -s /bin/bash -G appuser -g appuser appuser

# Répertoire de travail
WORKDIR /app

# Copier les fichiers package pour cache Docker
COPY package*.json ./

# Installer toutes les dépendances (dev + prod)
RUN npm install && npm cache clean --force

# Copier tout le code source React
COPY . .

# Créer les répertoires nécessaires
RUN mkdir -p /var/log/nginx /etc/nginx/ssl /var/www/html && \
    chown -R appuser:appuser /app /var/log/nginx /etc/nginx/ssl /var/www/html

# Copier la configuration nginx
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Script de démarrage multi-mode
COPY start-container.sh /usr/local/bin/start-container.sh
RUN chmod +x /usr/local/bin/start-container.sh

# Changer d'utilisateur
USER appuser

# Exposer les ports
EXPOSE 3000 80 443

# Health check intelligent
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD if [ "$NODE_ENV" = "development" ]; then \
          curl -f http://localhost:3000 || exit 1; \
        else \
          curl -f http://localhost/nginx-health || exit 1; \
        fi

# Volumes pour le développement
VOLUME ["/app/node_modules", "/app/dist", "/etc/nginx/ssl"]

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/start-container.sh"] 