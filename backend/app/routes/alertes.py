from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required

from app.models.alerte import Alerte
from app.extensions import limiter

alertes_bp = Blueprint("alertes", __name__, url_prefix="/api/alertes")


@alertes_bp.get("")
@jwt_required()
@limiter.limit("10 per minute")
def lister_alertes():
    alertes = Alerte.query.filter_by(actif=True).order_by(Alerte.created_at.desc()).limit(10).all()
    return jsonify([a.to_dict() for a in alertes]), 200
