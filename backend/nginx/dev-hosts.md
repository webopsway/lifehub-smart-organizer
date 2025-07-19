# Configuration des hosts locaux pour LifeHub

Pour une meilleure expérience de développement avec SSL, vous pouvez ajouter une entrée dans votre fichier hosts local.

## 🔧 Configuration

### Sur macOS/Linux :

1. Ouvrir le terminal
2. Éditer le fichier hosts :
   ```bash
   sudo nano /etc/hosts
   ```

3. Ajouter cette ligne :
   ```
   127.0.0.1    lifehub.local
   ```

4. Sauvegarder et fermer

### Sur Windows :

1. Ouvrir le Bloc-notes en tant qu'administrateur
2. Ouvrir le fichier : `C:\Windows\System32\drivers\etc\hosts`
3. Ajouter cette ligne :
   ```
   127.0.0.1    lifehub.local
   ```
4. Sauvegarder

## 🌐 Utilisation

Après configuration, vous pourrez accéder à l'application via :
- https://lifehub.local (au lieu de https://localhost)
- https://lifehub.local/api (API)
- https://lifehub.local/docs (Documentation)

## ⚠️ Note

Cette configuration est optionnelle. L'application fonctionne parfaitement avec `localhost`. 