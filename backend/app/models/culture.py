from app.extensions import db


class Culture(db.Model):
    """Référentiel des cultures suivies par AgroSense (sous-ensemble des 100
    cultures camerounaises classées par AgroPredict en 8 catégories
    agronomiques)."""

    __tablename__ = "cultures"

    id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(80), unique=True, nullable=False)
    categorie_agronomique = db.Column(db.String(80), nullable=False)
    couleur = db.Column(db.String(9), nullable=False, default="#2E6B28")  # hex

    # Paramètres utilisés par le modèle de rendement (valeurs de référence,
    # affinées ensuite par le Random Forest à partir des données collectées)
    rendement_reference_kg_ha = db.Column(db.Float, nullable=False, default=1500.0)
    cycle_jours = db.Column(db.Integer, nullable=True)  # durée du cycle (court = < 120j)

    # Utilisés par le moteur de recommandation (score de culture)
    sols_favorables = db.Column(db.String(200), nullable=False, default="Limoneux (équilibré)")
    saison_favorable = db.Column(db.String(40), nullable=False, default="Grande saison des pluies")
    tolerance_secheresse = db.Column(db.Boolean, default=False)

    prix_records = db.relationship("PrixRecord", backref="culture", lazy="dynamic")
    parcelles = db.relationship("Parcelle", backref="culture", lazy="dynamic")

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "nom": self.nom,
            "categorie_agronomique": self.categorie_agronomique,
            "couleur": self.couleur,
            "cycle_jours": self.cycle_jours,
        }
