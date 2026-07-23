from datetime import date

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError

from app.extensions import db, limiter
from app.models.user import User
from app.models.parcelle import Parcelle
from app.models.culture import Culture
from app.models.rendement import RendementPrediction
from app.models.alerte import Alerte
from app.schemas.culture_schema import ajouter_parcelle_schema
from app.utils.validation import reponse_erreur_validation

profil_bp = Blueprint("profil", __name__, url_prefix="/api/profil")


@profil_bp.get("")
@jwt_required()
@limiter.limit("15 per minute")
def profil():
    user_id = int(get_jwt_identity())
    utilisateur = User.query.get_or_404(user_id)
    parcelles = utilisateur.parcelles.all()

    superficie_totale = sum(p.superficie_ha for p in parcelles)
    nb_predictions = RendementPrediction.query.filter_by(user_id=user_id).count()
    nb_recommandations = Culture.query.count()
    nb_alertes = Alerte.query.filter_by(actif=True).count()

    return jsonify({
        "utilisateur": utilisateur.to_dict(),
        "stats": {
            "nb_cultures": len(parcelles),
            "annees_experience": utilisateur.annees_experience,
            "superficie_totale_ha": round(superficie_totale, 1),
        },
        "mes_cultures": [p.to_dict() for p in parcelles],
        "resume_previsions": {
            "nb_previsions": nb_predictions,
            "nb_recommandations": nb_recommandations,
            "nb_alertes": nb_alertes,
        },
    }), 200


@profil_bp.post("/parcelles")
@jwt_required()
@limiter.limit("10 per minute")
def ajouter_parcelle():
    user_id = int(get_jwt_identity())
    try:
        donnees = ajouter_parcelle_schema.load(request.get_json(silent=True) or {})
    except ValidationError as exc:
        return reponse_erreur_validation(exc)

    culture = Culture.query.get_or_404(donnees["culture_id"])
    parcelle = Parcelle(
        user_id=user_id,
        culture_id=culture.id,
        superficie_ha=donnees["superficie_ha"],
        type_sol=donnees["type_sol"],
        statut=donnees["statut"],
        date_plantation=date.today(),
    )
    db.session.add(parcelle)
    db.session.commit()

    return jsonify(parcelle.to_dict()), 201
