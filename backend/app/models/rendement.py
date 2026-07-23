from datetime import datetime
from app.extensions import db


class RendementPrediction(db.Model):
    """Historique des simulations de rendement + prix réalisées par un
    agriculteur depuis l'écran 'Rendements' de l'application mobile.

    Le profil de campagne complet (21 caractéristiques ML : sol, saison,
    engrais, mécanisation, etc.) est conservé dans `profil` (JSON) pour
    traçabilité — plutôt que dupliqué en colonnes individuelles, pour rester
    synchronisé avec app/ml/features.py sans migration à chaque évolution du
    formulaire.
    """

    __tablename__ = "rendement_predictions"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    culture_id = db.Column(db.Integer, db.ForeignKey("cultures.id"), nullable=False)

    superficie_ha = db.Column(db.Float, nullable=False)
    profil = db.Column(db.JSON, nullable=False, default=dict)  # 21 champs de campagne (voir app/ml/features.py)

    rendement_estime_kg_ha = db.Column(db.Float, nullable=False)
    prix_estime_fcfa_kg = db.Column(db.Float, nullable=False)
    production_totale_kg = db.Column(db.Float, nullable=False)
    revenu_estime_fcfa = db.Column(db.Float, nullable=False)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    culture = db.relationship("Culture")

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "culture": self.culture.to_dict(),
            "superficie_ha": self.superficie_ha,
            "type_sol": self.profil.get("type_sol"),
            "saison": self.profil.get("saison"),
            "profil": self.profil,
            "rendement_estime_kg_ha": round(self.rendement_estime_kg_ha, 1),
            "rendement_estime_t_ha": round(self.rendement_estime_kg_ha / 1000, 2),
            "prix_estime_fcfa_kg": round(self.prix_estime_fcfa_kg, 1),
            "production_totale_kg": round(self.production_totale_kg, 1),
            "revenu_estime_fcfa": round(self.revenu_estime_fcfa, 0),
            "created_at": self.created_at.isoformat(),
        }
