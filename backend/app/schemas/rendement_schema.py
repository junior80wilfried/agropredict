"""Schémas de validation pour les routes de prédiction de rendement/prix.

POST /api/rendement/predire retourne désormais rendement + prix + revenu
estimés, à partir du profil complet de campagne attendu par les modèles ML
(voir app/ml/features.py — source unique de vérité pour les champs et leurs
valeurs valides).

'culture' et 'type_culture' ne sont PAS demandés ici : ce sont des
propriétés intrinsèques de la culture choisie (culture_id), déduites côté
service depuis la table Culture — pas des choix de campagne du fermier.
"""
from __future__ import annotations

from marshmallow import Schema, fields, validate

from app.ml.features import (
    NOMINAL_FIELDS, ORDINAL_FIELDS, ORDRES, VALEURS_NOMINALES, DEFAULTS,
)

# Champs intrinsèques à la culture (pas au fermier) : déduits de culture_id,
# jamais demandés dans le formulaire.
_CHAMPS_DERIVES_DE_LA_CULTURE = {"culture", "type_culture"}
_CHAMPS_CAMPAGNE_NOMINAUX = [c for c in NOMINAL_FIELDS if c not in _CHAMPS_DERIVES_DE_LA_CULTURE]


def _champs_dynamiques() -> dict:
    """Génère les champs marshmallow pour les 21 caractéristiques de campagne
    (nominales + ordinales), directement depuis app.ml.features — pour ne
    jamais désynchroniser schéma et modèles ML."""
    champs = {
        "culture_id": fields.Integer(required=True, validate=validate.Range(min=1)),
        "superficie_ha": fields.Float(required=True, validate=validate.Range(min=0.01, max=100000)),
        "annee_campagne": fields.Integer(
            load_default=DEFAULTS["annee_campagne"], validate=validate.Range(min=2015, max=2035)
        ),
    }

    for nom_champ in _CHAMPS_CAMPAGNE_NOMINAUX:
        champs[nom_champ] = fields.String(
            load_default=DEFAULTS.get(nom_champ),
            allow_none=True,
            validate=validate.OneOf(VALEURS_NOMINALES[nom_champ]),
        )

    for nom_champ in ORDINAL_FIELDS:
        champs[nom_champ] = fields.String(
            load_default=DEFAULTS.get(nom_champ),
            allow_none=True,
            validate=validate.OneOf(ORDRES[nom_champ]),
        )

    return champs


# Schéma construit dynamiquement depuis app.ml.features (Schema.from_dict est
# l'API publique marshmallow prévue pour ça — pas de dépendance à des
# attributs internes de la métaclasse).
PredireRendementSchema = Schema.from_dict(_champs_dynamiques(), name="PredireRendementSchema")


class HistoriqueRendementSchema(Schema):
    """Valide les paramètres de requête de GET /api/rendement/historique."""

    culture_id = fields.Integer(required=False, load_default=None, allow_none=True,
                                 validate=validate.Range(min=1))


predire_rendement_schema = PredireRendementSchema()
historique_rendement_schema = HistoriqueRendementSchema()
