import os
import secrets
from datetime import timedelta
from dotenv import load_dotenv

load_dotenv()


def _env_bool(nom: str, defaut: bool) -> bool:
    """Lit une variable d'environnement booléenne (1/true/yes/on), sinon `defaut`."""
    valeur = os.getenv(nom)
    if valeur is None:
        return defaut
    return valeur.strip().lower() in ("1", "true", "yes", "on")


class Config:
    """Configuration de base, commune à tous les environnements."""

    # Sécurisé par défaut : chaque environnement doit activer DEBUG explicitement.
    DEBUG = False
    TESTING = False

    # Génération de clés secrètes aléatoires si non fournies
    SECRET_KEY = os.getenv("SECRET_KEY") or secrets.token_hex(32)
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY") or secrets.token_hex(32)
    
    # Configuration JWT
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(
        minutes=int(os.getenv("JWT_ACCESS_TOKEN_EXPIRES_MIN", 1440))
    )
    JWT_TOKEN_LOCATION = ["headers", "cookies", "json", "query_string"]
    JWT_COOKIE_SECURE = _env_bool("JWT_COOKIE_SECURE", True)
    JWT_COOKIE_CSRF_PROTECT = _env_bool("JWT_COOKIE_CSRF_PROTECT", True)
    JWT_CSRF_CHECK_FORM = True

    # Base de données
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "postgresql://agrosense_user:agrosense_pass@localhost:5433/agrosense_db",
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 10,
        'max_overflow': 20,
        'pool_timeout': 30,
        'pool_recycle': 3600,
    }

    # CORS - Origines autorisées (séparées par des virgules)
    CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000")
    CORS_SUPPORT_CREDENTIALS = True
    CORS_MAX_AGE = 86400  # 24 heures

    # Sécurité HTTP
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16 Mo max pour les requêtes
    SESSION_COOKIE_SECURE = _env_bool("SESSION_COOKIE_SECURE", True)
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = "Lax"

    # Timeout des requêtes (en secondes)
    REQUEST_TIMEOUT = int(os.getenv("REQUEST_TIMEOUT", 30))


class DevelopmentConfig(Config):
    """Configuration pour le développement local."""
    # Désactivé par défaut pour éviter les fuites d'informations
    DEBUG = _env_bool("FLASK_DEBUG", False)
    SQLALCHEMY_ECHO = _env_bool("SQLALCHEMY_ECHO", False)
    SESSION_COOKIE_SECURE = False  # Pour le développement local
    JWT_COOKIE_SECURE = False


class ProductionConfig(Config):
    """Configuration pour la production."""
    # Valeur figée, volontairement NON pilotée par une variable d'environnement
    DEBUG = False
    SESSION_COOKIE_SECURE = True
    JWT_COOKIE_SECURE = True


class TestingConfig(Config):
    """Configuration pour les tests."""
    TESTING = True
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
    WTF_CSRF_ENABLED = False
    JWT_COOKIE_SECURE = False


config_by_name = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
    "testing": TestingConfig,
}
