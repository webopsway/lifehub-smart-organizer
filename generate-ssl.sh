#!/bin/bash

# Script pour générer des certificats SSL auto-signés pour le frontend LifeHub

echo "🔐 Génération des certificats SSL pour le frontend..."

# Créer le dossier SSL s'il n'existe pas
mkdir -p nginx/ssl

# Générer la clé privée
openssl genrsa -out nginx/ssl/lifehub.key 2048

# Générer le certificat auto-signé
openssl req -new -x509 -key nginx/ssl/lifehub.key -out nginx/ssl/lifehub.crt -days 365 \
    -subj "/C=FR/ST=IDF/L=Paris/O=LifeHub/OU=Frontend/CN=localhost/emailAddress=dev@lifehub.local" \
    -addext "subjectAltName=DNS:localhost,DNS:lifehub.local,DNS:*.lifehub.local,IP:127.0.0.1"

# Permissions appropriées
chmod 600 nginx/ssl/lifehub.key
chmod 644 nginx/ssl/lifehub.crt

echo "✅ Certificats SSL générés avec succès pour le frontend !"
echo "📁 Fichiers créés :"
echo "   - nginx/ssl/lifehub.key (clé privée)"
echo "   - nginx/ssl/lifehub.crt (certificat)"
echo ""
echo "⚠️  Ces certificats sont auto-signés et destinés au développement uniquement."
echo "   Votre navigateur affichera un avertissement de sécurité que vous devrez accepter."
echo ""
echo "🌐 Le frontend sera accessible via :"
echo "   - https://localhost"
echo "   - https://lifehub.local (après configuration hosts)" 