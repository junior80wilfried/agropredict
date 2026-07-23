from app.extensions import db


class Marche(db.Model):
    __tablename__ = "marches"

    id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(150), nullable=False)
    ville = db.Column(db.String(120), nullable=False)
    region = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=True)
    longitude = db.Column(db.Float, nullable=True)

    prix_records = db.relationship("PrixRecord", backref="marche", lazy="dynamic")

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "nom": self.nom,
            "ville": self.ville,
            "region": self.region,
        }
