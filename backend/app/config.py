import os
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

    SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-key")
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "dev-jwt-secret")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(
        minutes=int(os.getenv("JWT_ACCESS_TOKEN_EXPIRES_MIN", 1440))
    )

    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "postgresql://agrosense_user:agrosense_pass@localhost:5433/agrosense_db",
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False


class DevelopmentConfig(Config):
    # Activable/désactivable localement via FLASK_DEBUG dans le .env (jamais commité).
    # Par défaut True uniquement ici, car cette classe n'est jamais utilisée en production.
    DEBUG = _env_bool("FLASK_DEBUG", True)


class ProductionConfig(Config):
    # Valeur figée, volontairement NON pilotée par une variable d'environnement :
    # une mauvaise config d'env en prod ne pourra jamais réactiver le debug.
    DEBUG = False


class TestingConfig(Config):
    TESTING = True
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"


config_by_name = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
    "testing": TestingConfig,
}
