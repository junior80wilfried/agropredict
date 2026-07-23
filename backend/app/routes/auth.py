from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError

from app.models.user import User
from app.services.auth_service import inscrire_utilisateur, connecter_utilisateur, AuthError
from app.schemas.auth_schema import inscription_schema, connexion_schema, utilisateur_public_schema
from app.utils.validation import reponse_erreur_validation

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")


@auth_bp.post("/inscription")
def inscription():
    try:
        donnees_validees = inscription_schema.load(request.get_json(silent=True) or {})
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    try:
        utilisateur, token = inscrire_utilisateur(donnees_validees)
    except AuthError as e:
        return jsonify({"erreur": e.message}), e.status_code

    return jsonify({"utilisateur": utilisateur_public_schema.dump(utilisateur), "token": token}), 201


@auth_bp.post("/connexion")
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
