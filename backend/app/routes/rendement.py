from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError

from app.ml.features import NOMINAL_FIELDS, ORDINAL_FIELDS, ORDRES, VALEURS_NOMINALES
from app.services.rendement_service import calculer_rendement, historique_rendements, RendementError
from app.schemas.rendement_schema import predire_rendement_schema, historique_rendement_schema
from app.utils.validation import reponse_erreur_validation

rendement_bp = Blueprint("rendement", __name__, url_prefix="/api/rendement")

_CHAMPS_FORMULAIRE = [c for c in NOMINAL_FIELDS if c not in ("culture", "type_culture")]


@rendement_bp.get("/champs")
@jwt_required()
def champs_formulaire():
    """Valeurs valides pour chaque champ du formulaire de prédiction (21
    champs de campagne), pour construire dynamiquement les listes
    déroulantes côté app mobile sans les dupliquer en dur dans Flutter."""
    return jsonify({
        "nominaux": {champ: VALEURS_NOMINALES[champ] for champ in _CHAMPS_FORMULAIRE},
        "ordinaux": {champ: ORDRES[champ] for champ in ORDINAL_FIELDS},
    }), 200


@rendement_bp.post("/predire")
@jwt_required()
def predire():
    user_id = int(get_jwt_identity())
    try:
        donnees = predire_rendement_schema.load(request.get_json(silent=True) or {})
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    try:
        prediction = calculer_rendement(user_id, donnees)
    except RendementError as e:
        return jsonify({"erreur": e.message}), e.status_code

    return jsonify(prediction.to_dict()), 201


@rendement_bp.get("/historique")
@jwt_required()
def historique():
    user_id = int(get_jwt_identity())
    try:
        donnees = historique_rendement_schema.load(request.args)
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    predictions = historique_rendements(user_id, donnees["culture_id"])
    return jsonify([p.to_dict() for p in predictions]), 200
