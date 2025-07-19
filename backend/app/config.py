from pydantic_settings import BaseSettings
from pydantic import Field
from typing import List
import os


class Settings(BaseSettings):
    """Configuration de l'application LifeHub"""
    
    # === BASE DE DONNÉES ===
    mysql_host: str = Field(default="localhost", description="Adresse du serveur MySQL")
    mysql_port: int = Field(default=3306, description="Port MySQL")
    mysql_user: str = Field(default="lifehub_user", description="Utilisateur MySQL")
    mysql_password: str = Field(default="lifehub_password", description="Mot de passe MySQL")
    mysql_database: str = Field(default="lifehub_db", description="Nom de la base de données")
    
    # Pool de connexions
    mysql_pool_size: int = Field(default=20, description="Taille du pool de connexions")
    mysql_max_overflow: int = Field(default=30, description="Connexions supplémentaires")
    mysql_pool_timeout: int = Field(default=30, description="Timeout du pool")
    mysql_pool_recycle: int = Field(default=3600, description="Recyclage des connexions")
    
    @property
    def database_url(self) -> str:
        """URL de connexion à la base de données"""
        return f"mysql+pymysql://{self.mysql_user}:{self.mysql_password}@{self.mysql_host}:{self.mysql_port}/{self.mysql_database}"
    
    # === REDIS CACHE ===
    redis_host: str = Field(default="localhost", description="Adresse du serveur Redis")
    redis_port: int = Field(default=6379, description="Port Redis")
    redis_password: str = Field(default="", description="Mot de passe Redis")
    redis_db: int = Field(default=0, description="Base de données Redis")
    redis_url: str = Field(default="redis://localhost:6379/0", description="URL Redis complète")
    
    # Cache settings
    redis_timeout: int = Field(default=300, description="Timeout Redis")
    redis_max_connections: int = Field(default=100, description="Connexions max Redis")
    
    # === SÉCURITÉ ===
    secret_key: str = Field(default="changeme", description="Clé secrète JWT")
    algorithm: str = Field(default="HS256", description="Algorithme JWT")
    access_token_expire_minutes: int = Field(default=30, description="Durée du token")
    
    # CORS
    frontend_url: str = Field(default="https://localhost", description="URL du frontend")
    allowed_origins: str = Field(
        default="https://localhost,https://lifehub.local,http://localhost:5173",
        description="Origines CORS autorisées (séparées par virgules)"
    )
    
    @property
    def allowed_origins_list(self) -> List[str]:
        """Liste des origines CORS autorisées"""
        return [origin.strip() for origin in self.allowed_origins.split(",")]
    
    # === API CONFIGURATION ===
    api_host: str = Field(default="0.0.0.0", description="Adresse d'écoute API")
    api_port: int = Field(default=8000, description="Port d'écoute API")
    api_prefix: str = Field(default="/api", description="Préfixe des routes API")
    api_version: str = Field(default="v1", description="Version de l'API")
    
    # === ENVIRONNEMENT ===
    environment: str = Field(default="development", description="Environnement")
    debug: bool = Field(default=False, description="Mode debug")
    log_level: str = Field(default="INFO", description="Niveau de log")
    
    # === LOGGING ===
    log_format: str = Field(
        default="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        description="Format des logs"
    )
    log_file: str = Field(default="/app/logs/lifehub.log", description="Fichier de log")
    log_max_size: str = Field(default="50MB", description="Taille max du fichier log")
    log_backup_count: int = Field(default=5, description="Nombre de fichiers de sauvegarde")
    
    # === UPLOAD/STOCKAGE ===
    upload_dir: str = Field(default="/app/data/uploads", description="Répertoire uploads")
    max_upload_size: str = Field(default="10MB", description="Taille max upload")
    allowed_extensions: str = Field(
        default="jpg,jpeg,png,gif,pdf,doc,docx",
        description="Extensions autorisées"
    )
    
    @property
    def allowed_extensions_list(self) -> List[str]:
        """Liste des extensions autorisées"""
        return [ext.strip().lower() for ext in self.allowed_extensions.split(",")]
    
    # === PERFORMANCE ===
    workers: int = Field(default=4, description="Nombre de workers")
    worker_connections: int = Field(default=1000, description="Connexions par worker")
    keepalive: int = Field(default=2, description="Keepalive timeout")
    
    # === MONITORING ===
    enable_metrics: bool = Field(default=True, description="Activer les métriques")
    metrics_port: int = Field(default=9090, description="Port des métriques")
    
    # === FEATURES ===
    enable_registration: bool = Field(default=True, description="Autoriser l'inscription")
    enable_email_verification: bool = Field(default=False, description="Vérification email")
    enable_password_reset: bool = Field(default=True, description="Reset de mot de passe")
    enable_rate_limiting: bool = Field(default=True, description="Limitation de débit")
    
    # Rate limiting
    rate_limit_requests: int = Field(default=100, description="Requêtes par fenêtre")
    rate_limit_window: int = Field(default=60, description="Fenêtre en secondes")
    
    # === BACKUP ===
    backup_enabled: bool = Field(default=True, description="Activer les sauvegardes")
    backup_schedule: str = Field(default="0 2 * * *", description="Planning sauvegarde")
    backup_retention_days: int = Field(default=30, description="Rétention en jours")
    
    class Config:
        # Charger depuis le fichier .env monté
        env_file = "/app/.env"
        env_file_encoding = "utf-8"
        case_sensitive = False
        
        # Validation des champs
        validate_assignment = True
        
        # Documentation des champs
        schema_extra = {
            "description": "Configuration de l'application LifeHub",
            "example": {
                "mysql_host": "mysql",
                "redis_host": "redis",
                "secret_key": "your-secret-key",
                "environment": "production"
            }
        }


# Instance globale des paramètres
settings = Settings()


def get_settings() -> Settings:
    """Récupérer la configuration de l'application"""
    return settings


# Validation des paramètres au chargement
def validate_settings():
    """Valider la configuration au démarrage"""
    errors = []
    
    # Vérification de la clé secrète
    if settings.secret_key == "changeme" or len(settings.secret_key) < 32:
        errors.append("SECRET_KEY doit être définie et faire au moins 32 caractères")
    
    # Vérification de l'environnement
    valid_environments = ["development", "testing", "production"]
    if settings.environment not in valid_environments:
        errors.append(f"ENVIRONMENT doit être dans {valid_environments}")
    
    # Vérification des répertoires
    os.makedirs(os.path.dirname(settings.log_file), exist_ok=True)
    os.makedirs(settings.upload_dir, exist_ok=True)
    
    if errors:
        raise ValueError("Erreurs de configuration:\n" + "\n".join(f"- {error}" for error in errors))


# Fonction utilitaire pour afficher la configuration
def print_settings():
    """Afficher la configuration (sans les secrets)"""
    config_info = {
        "Environment": settings.environment,
        "Debug": settings.debug,
        "API Host": f"{settings.api_host}:{settings.api_port}",
        "Database": f"{settings.mysql_host}:{settings.mysql_port}/{settings.mysql_database}",
        "Redis": f"{settings.redis_host}:{settings.redis_port}/{settings.redis_db}",
        "Frontend URL": settings.frontend_url,
        "Log Level": settings.log_level,
        "Log File": settings.log_file,
        "Upload Dir": settings.upload_dir,
    }
    
    print("📋 Configuration LifeHub:")
    print("=" * 25)
    for key, value in config_info.items():
        print(f"   {key:15} : {value}")
    print()


# Valider au chargement du module
try:
    validate_settings()
except ValueError as e:
    print(f"❌ Erreur de configuration: {e}")
    exit(1) 