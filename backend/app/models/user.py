from datetime import datetime, date
from werkzeug.security import generate_password_hash, check_password_hash
from app.extensions import db


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(180), unique=True, nullable=False, index=True)
    telephone = db.Column(db.String(30), nullable=True)
    password_hash = db.Column(db.String(255), nullable=False)

    ville = db.Column(db.String(120), nullable=True, default="Yaoundé")
    region = db.Column(db.String(120), nullable=True, default="Centre")
    agriculteur_depuis = db.Column(db.Integer, nullable=True)  # année, ex: 2015

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    parcelles = db.relationship(
        "Parcelle", backref="proprietaire", lazy="dynamic", cascade="all, delete-orphan"
    )
    predictions_rendement = db.relationship(
        "RendementPrediction", backref="auteur", lazy="dynamic", cascade="all, delete-orphan"
    )

    def set_password(self, mot_de_passe: str) -> None:
        self.password_hash = generate_password_hash(mot_de_passe)

    def check_password(self, mot_de_passe: str) -> bool:
        return check_password_hash(self.password_hash, mot_de_passe)

    @property
    def initiales(self) -> str:
        parties = self.nom.strip().split()
        if len(parties) >= 2:
            return (parties[0][0] + parties[1][0]).upper()
        return self.nom[:2].upper() if self.nom else "??"

    @property
    def annees_experience(self) -> int:
        if not self.agriculteur_depuis:
            return 0
        return date.today().year - self.agriculteur_depuis

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "nom": self.nom,
            "email": self.email,
            "telephone": self.telephone,
            "ville": self.ville,
            "region": self.region,
            "agriculteur_depuis": self.agriculteur_depuis,
            "annees_experience": self.annees_experience,
            "initiales": self.initiales,
        }
