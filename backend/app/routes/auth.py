from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from marshmallow import ValidationError

from app.models.user import User
from app.services.auth_service import (
    inscrire_utilisateur, 
    connecter_utilisateur, 
    AuthError,
    verifier_email
)
from app.schemas.auth_schema import (
    inscription_schema, 
    connexion_schema, 
    utilisateur_public_schema
)
from app.utils.validation import reponse_erreur_validation, reponse_erreur_authentification
from app.extensions import limiter

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")

# Configuration spécifique du rate limiting pour l'auth
auth_limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"
)


@auth_bp.post("/inscription")
@auth_limiter.limit("5 per minute")
def inscription():
    try:
        donnees_validees = inscription_schema.load(request.get_json(silent=True) or {})
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    try:
        utilisateur, token = inscrire_utilisateur(donnees_validees)
    except AuthError as e:
        return jsonify({"erreur": e.message}), e.status_code

    return jsonify({
        "utilisateur": utilisateur_public_schema.dump(utilisateur), 
        "token": token,
        "message": "Inscription réussie. Veuillez vérifier votre email pour activer votre compte."
    }), 201


@auth_bp.post("/connexion")
@auth_limiter.limit("5 per minute")
def connexion():
    try:
        donnees_validees = connexion_schema.load(request.get_json(silent=True) or {})
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    try:
        utilisateur, token = connecter_utilisateur(donnees_validees)
    except AuthError as e:
        return jsonify({"erreur": e.message}), e.status_code

    return jsonify({"utilisateur": utilisateur_public_schema.dump(utilisateur), "token": token}), 200


@auth_bp.get("/moi")
@jwt_required()
def moi():
    utilisateur = User.query.get_or_404(int(get_jwt_identity()))
    return jsonify(utilisateur_public_schema.dump(utilisateur)), 200


@auth_bp.get("/verifier-email/<token>")
def verifier_email_route(token: str):
    """Endpoint pour vérifier l'email via un token."""
    utilisateur = verifier_email(token)
    if not utilisateur:
        return jsonify({"erreur": "Token de vérification invalide ou expiré."}), 400
    
    return jsonify({
        "message": "Email vérifié avec succès. Vous pouvez maintenant vous connecter.",
        "utilisateur": utilisateur_public_schema.dump(utilisateur)
    }), 200


@auth_bp.post("/rafraichir-token")
@jwt_required()
def rafraichir_token():
    """Rafraîchit le token JWT pour un utilisateur authentifié."""
    identity = get_jwt_identity()
    utilisateur = User.query.get_or_404(int(identity))
    
    nouveau_token = create_access_token(identity=str(utilisateur.id))
    return jsonify({"token": nouveau_token}), 200
