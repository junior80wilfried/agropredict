from app.routes.auth import auth_bp
from app.routes.prix import prix_bp
from app.routes.rendement import rendement_bp
from app.routes.cultures import cultures_bp
from app.routes.profil import profil_bp
from app.routes.alertes import alertes_bp


def register_blueprints(app):
    app.register_blueprint(auth_bp)
    app.register_blueprint(prix_bp)
    app.register_blueprint(rendement_bp)
    app.register_blueprint(cultures_bp)
    app.register_blueprint(profil_bp)
    app.register_blueprint(alertes_bp)
