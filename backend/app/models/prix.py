from datetime import datetime, timezone
from app.extensions import db


class PrixRecord(db.Model):
    """Point d'historique de prix réel pour une culture, sur un marché, à une
    date donnée. Sert à afficher la tendance de marché (écran "Prix") — la
    prédiction de prix par campagne, elle, vient de modele_prix.joblib (voir
    app/ml/), pas de cet historique."""

    __tablename__ = "prix_records"

    id = db.Column(db.Integer, primary_key=True)
    culture_id = db.Column(db.Integer, db.ForeignKey("cultures.id"), nullable=False)
    marche_id = db.Column(db.Integer, db.ForeignKey("marches.id"), nullable=False)

    date = db.Column(db.Date, nullable=False, index=True)
    prix_fcfa_kg = db.Column(db.Float, nullable=False)

    created_at = db.Column(
        db.DateTime, 
        default=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (
        db.Index("ix_prix_culture_marche_date", "culture_id", "marche_id", "date"),
    )

    def to_dict(self) -> dict:
        return {
            "date": self.date.isoformat(),
            "prix_fcfa_kg": round(self.prix_fcfa_kg, 1),
        }
