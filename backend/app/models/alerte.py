from datetime import datetime
from app.extensions import db


class Alerte(db.Model):
    __tablename__ = "alertes"

    id = db.Column(db.Integer, primary_key=True)
    culture_id = db.Column(db.Integer, db.ForeignKey("cultures.id"), nullable=True)

    titre = db.Column(db.String(180), nullable=False)
    message = db.Column(db.String(300), nullable=False)
    type = db.Column(db.String(20), nullable=False, default="info")  # info | succes | alerte
    couleur = db.Column(db.String(9), nullable=False, default="#C8892A")

    region = db.Column(db.String(120), nullable=True)  # None = visible partout
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    actif = db.Column(db.Boolean, default=True)

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "titre": self.titre,
            "message": self.message,
            "type": self.type,
            "couleur": self.couleur,
            "created_at": self.created_at.isoformat(),
        }
