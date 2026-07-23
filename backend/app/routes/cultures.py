from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from marshmallow import ValidationError

from app.models.culture import Culture
from app.services.recommendation_service import recommander_cultures
from app.schemas.culture_schema import recommandation_culture_schema
from app.utils.validation import reponse_erreur_validation

cultures_bp = Blueprint("cultures", __name__, url_prefix="/api/cultures")


@cultures_bp.get("")
@jwt_required()
def lister_cultures():
    cultures = Culture.query.order_by(Culture.nom.asc()).all()
    return jsonify([c.to_dict() for c in cultures]), 200


@cultures_bp.get("/recommandations")
@jwt_required()
def recommandations():
    try:
        donnees = recommandation_culture_schema.load(request.args)
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    resultats = recommander_cultures(donnees)
    return jsonify(resultats), 200
