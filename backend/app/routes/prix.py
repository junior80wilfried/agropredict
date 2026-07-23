from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from marshmallow import ValidationError

from app.models.culture import Culture
from app.services.prix_service import resume_prix, marches_proches
from app.schemas.prix_schema import prix_culture_query_schema, marches_proches_query_schema
from app.utils.validation import reponse_erreur_validation

prix_bp = Blueprint("prix", __name__, url_prefix="/api/prix")


@prix_bp.get("/<int:culture_id>")
@jwt_required()
def prix_culture(culture_id: int):
    culture = Culture.query.get_or_404(culture_id)
    try:
        donnees = prix_culture_query_schema.load(request.args)
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    return jsonify(resume_prix(culture, donnees["marche_id"])), 200


@prix_bp.get("/<int:culture_id>/marches")
@jwt_required()
def marches_pour_culture(culture_id: int):
    Culture.query.get_or_404(culture_id)
    try:
        donnees = marches_proches_query_schema.load(request.args)
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    return jsonify(marches_proches(culture_id, donnees["ville"])), 200
