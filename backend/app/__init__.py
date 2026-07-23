from __future__ import annotations

import os
import logging
from logging.handlers import RotatingFileHandler
from flask import Flask, jsonify

from app.config import config_by_name
from app.extensions import db, migrate, jwt, cors, limiter
from app.routes import register_blueprints


def create_app(config_name: str | None = None) -> Flask:
    # Si FLASK_ENV n'est pas défini (ex. oubli sur un serveur de prod), on bascule
    # sur "production" par défaut plutôt que "development" — fail-safe, jamais
    # de DEBUG=True accidentel en dehors d'une machine de dev configurée.
    config_name = config_name or os.getenv("FLASK_ENV", "production")
    app = Flask(__name__)
    app.config.from_object(config_by_name[config_name])

    # Configuration du timeout des requêtes
    app.config['PERMANENT_SESSION_LIFETIME'] = app.config.get('REQUEST_TIMEOUT', 30)

    # Initialisation des extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    
    # Configuration CORS sécurisée
    cors_origins = app.config.get('CORS_ORIGINS', '').split(',')
    cors.init_app(
        app, 
        resources={r"/api/*": {"origins": cors_origins}},
        supports_credentials=app.config.get('CORS_SUPPORT_CREDENTIALS', True),
        max_age=app.config.get('CORS_MAX_AGE', 86400)
    )
    
    # Initialisation du rate limiting
    limiter.init_app(app)

    register_blueprints(app)

    # Configuration du logging
    if not app.debug:
        file_handler = RotatingFileHandler(
            'agrosense.log', 
            maxBytes=10485760,  # 10 Mo
            backupCount=10
        )
        file_handler.setFormatter(logging.Formatter(
            '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
        ))
        file_handler.setLevel(logging.INFO)
        app.logger.addHandler(file_handler)
        app.logger.setLevel(logging.INFO)
        app.logger.info('AgroSense startup')

    @app.get("/api/sante")
    def sante():
        return jsonify({"statut": "ok", "service": "AgroSense API"}), 200

    @app.errorhandler(400)
    def bad_request(e):
        return jsonify({"erreur": "Requête invalide. Vérifiez les données envoyées."}), 400

    @app.errorhandler(401)
    def unauthorized(e):
        return jsonify({"erreur": "Non autorisé. Veuillez vous authentifier."}), 401

    @app.errorhandler(403)
    def forbidden(e):
        return jsonify({"erreur": "Accès interdit."}), 403

    @app.errorhandler(404)
    def non_trouve(_e):
        return jsonify({"erreur": "Ressource introuvable."}), 404

    @app.errorhandler(405)
    def method_not_allowed(e):
        return jsonify({"erreur": "Méthode HTTP non autorisée."}), 405

    @app.errorhandler(413)
    def payload_too_large(e):
        return jsonify({"erreur": "La requête est trop volumineuse. Limite : 16 Mo."}), 413

    @app.errorhandler(429)
    def ratelimit_handler(e):
        return jsonify({"erreur": "Trop de requêtes. Veuillez réessayer plus tard."}), 429

    @app.errorhandler(500)
    def erreur_serveur(e):
        if app.debug:
            app.logger.error(f"Erreur serveur: {str(e)}", exc_info=True)
            return jsonify({
                "erreur": "Erreur interne du serveur",
                "details": str(e)
            }), 500
        app.logger.error(f"Erreur serveur: {str(e)}")
        return jsonify({"erreur": "Erreur interne du serveur. Veuillez réessayer plus tard."}), 500

    @app.cli.command("seed")
    def seed():
        """Peuple la base avec le jeu de données de démarrage (Cameroun)."""
        from app.seed.seed_data import seed_all
        seed_all()

    return app
