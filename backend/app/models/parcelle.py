from datetime import datetime
from app.extensions import db


class Parcelle(db.Model):
    """Une culture suivie par un agriculteur ("Mes cultures" côté mobile)."""

    __tablename__ = "parcelles"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    culture_id = db.Column(db.Integer, db.ForeignKey("cultures.id"), nullable=False)

    superficie_ha = db.Column(db.Float, nullable=False, default=1.0)
    type_sol = db.Column(db.String(80), nullable=True, default="Sableux (léger, sèche vite)")
    statut = db.Column(
        db.String(40), nullable=False, default="Planté"
    )  # Planté | En croissance | Récolte prochaine | Récolté
    date_plantation = db.Column(db.Date, nullable=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    STATUT_COULEURS = {
        "Planté": "#C8892A",
        "En croissance": "#2E6B28",
        "Récolte prochaine": "#7A4510",
        "Récolté": "#5C8A3C",
    }

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "culture": self.culture.to_dict(),
            "superficie_ha": self.superficie_ha,
            "type_sol": self.type_sol,
            "statut": self.statut,
            "statut_couleur": self.STATUT_COULEURS.get(self.statut, "#7A6E5A"),
            "date_plantation": self.date_plantation.isoformat() if self.date_plantation else None,
        }
