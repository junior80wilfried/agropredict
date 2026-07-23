"""Schémas de validation pour les routes cultures/parcelles.

Les valeurs autorisées pour le sol et la saison sont désormais alignées sur
le dataset d'entraînement des modèles ML (app/ml/features.py) — source
unique de vérité — plutôt que sur un référentiel local dupliqué.
"""

from marshmallow import Schema, fields, validate

from app.ml.features import VALEURS_NOMINALES

TYPES_SOL_VALIDES = VALEURS_NOMINALES["type_sol"]
SAISONS_VALIDES = VALEURS_NOMINALES["saison"]
STATUTS_PARCELLE_VALIDES = ["Planté", "En croissance", "Récolte prochaine", "Récolté"]


class RecommandationCulturesSchema(Schema):
    """Valide les paramètres de requête de GET /api/cultures/recommandations.

    Tous les champs sont optionnels : ceux non fournis prennent une valeur
    par défaut (app.ml.features.DEFAULTS) pour l'appel aux modèles ML.
    """

    type_sol = fields.String(load_default=None, allow_none=True, validate=validate.OneOf(TYPES_SOL_VALIDES))
    saison = fields.String(load_default=None, allow_none=True, validate=validate.OneOf(SAISONS_VALIDES))
    region = fields.String(load_default=None, allow_none=True)
    superficie_ha = fields.Float(load_default=1.0, validate=validate.Range(min=0.01, max=100000))


class AjouterParcelleSchema(Schema):
    """Valide le corps de requête de POST /api/profil/parcelles."""

    culture_id = fields.Integer(required=True, validate=validate.Range(min=1))
    superficie_ha = fields.Float(load_default=1.0, validate=validate.Range(min=0.01, max=100000))
    type_sol = fields.String(load_default=TYPES_SOL_VALIDES[0], validate=validate.OneOf(TYPES_SOL_VALIDES))
    statut = fields.String(load_default="Planté", validate=validate.OneOf(STATUTS_PARCELLE_VALIDES))


recommandation_culture_schema = RecommandationCulturesSchema()
ajouter_parcelle_schema = AjouterParcelleSchema()
