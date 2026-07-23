from __future__ import annotations

import os
from flask import Flask, jsonify

from app.config import config_by_name
from app.extensions import db, migrate, jwt, cors
from app.routes import register_blueprints


def create_app(config_name: str | None = None) -> Flask:
    # Si FLASK_ENV n'est pas défini (ex. oubli sur un serveur de prod), on bascule
    # sur "production" par défaut plutôt que "development" — fail-safe, jamais
    # de DEBUG=True accidentel en dehors d'une machine de dev configurée.
    config_name = config_name or os.getenv("FLASK_ENV", "production")
    app = Flask(__name__)
    app.config.from_object(config_by_name[config_name])

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    cors.init_app(app, resources={r"/api/*": {"origins": "*"}})

    register_blueprints(app)

    @app.get("/api/sante")
    def sante():
        return jsonify({"statut": "ok", "service": "AgroSense API"}), 200

    @app.errorhandler(404)
    def non_trouve(_e):
        return jsonify({"erreur": "Ressource introuvable."}), 404

    @app.errorhandler(500)
    def erreur_serveur(_e):
        return jsonify({"erreur": "Erreur interne du serveur."}), 500

    @app.cli.command("seed")
    def seed():
        """Peuple la base avec le jeu de données de démarrage (Cameroun)."""
        from app.seed.seed_data import seed_all
        seed_all()

    return app
