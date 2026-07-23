"""Instances des extensions Flask, partagées dans toute l'application.

Elles sont créées ici sans être liées à une app précise, puis initialisées
dans create_app() via extension.init_app(app) (pattern "application factory").
"""
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
cors = CORS()
