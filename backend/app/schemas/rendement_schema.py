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


class PredireRendementSchema(Schema):
    """Schémas de validation pour POST /api/rendement/predire."""
    
    culture_id = fields.Integer(required=True, validate=validate.Range(min=1))
    superficie_ha = fields.Float(required=True, validate=validate.Range(min=0.01, max=100000))
    annee_campagne = fields.Integer(
        load_default=DEFAULTS["annee_campagne"], 
        validate=validate.Range(min=2015, max=2035)
    )

    # Champs nominaux
    variete_semence = fields.String(
        load_default=DEFAULTS.get("variete_semence"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["variete_semence"]),
    )
    mode_mise_en_terre = fields.String(
        load_default=DEFAULTS.get("mode_mise_en_terre"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["mode_mise_en_terre"]),
    )
    region = fields.String(
        load_default=DEFAULTS.get("region"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["region"]),
    )
    zone_agro_ecologique = fields.String(
        load_default=DEFAULTS.get("zone_agro_ecologique"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["zone_agro_ecologique"]),
    )
    saison = fields.String(
        load_default=DEFAULTS.get("saison"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["saison"]),
    )
    type_sol = fields.String(
        load_default=DEFAULTS.get("type_sol"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["type_sol"]),
    )
    mode_approvisionnement_eau = fields.String(
        load_default=DEFAULTS.get("mode_approvisionnement_eau"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["mode_approvisionnement_eau"]),
    )
    traitement_phytosanitaire = fields.String(
        load_default=DEFAULTS.get("traitement_phytosanitaire"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["traitement_phytosanitaire"]),
    )
    systeme_culture = fields.String(
        load_default=DEFAULTS.get("systeme_culture"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["systeme_culture"]),
    )
    rotation_culturale = fields.String(
        load_default=DEFAULTS.get("rotation_culturale"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["rotation_culturale"]),
    )
    mois_mise_en_terre = fields.String(
        load_default=DEFAULTS.get("mois_mise_en_terre"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["mois_mise_en_terre"]),
    )
    utilisation_engrais = fields.String(
        load_default=DEFAULTS.get("utilisation_engrais"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["utilisation_engrais"]),
    )
    type_engrais_mineral = fields.String(
        load_default=DEFAULTS.get("type_engrais_mineral"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["type_engrais_mineral"]),
    )
    accompagnement_technique = fields.String(
        load_default=DEFAULTS.get("accompagnement_technique"),
        allow_none=True,
        validate=validate.OneOf(VALEURS_NOMINALES["accompagnement_technique"]),
    )

    # Champs ordinaux
    altitude = fields.String(
        load_default=DEFAULTS.get("altitude"),
        allow_none=True,
        validate=validate.OneOf(ORDRES["altitude"]),
    )
    pluviometrie = fields.String(
        load_default=DEFAULTS.get("pluviometrie"),
        allow_none=True,
        validate=validate.OneOf(ORDRES["pluviometrie"]),
    )
    fertilite_sol = fields.String(
        load_default=DEFAULTS.get("fertilite_sol"),
        allow_none=True,
        validate=validate.OneOf(ORDRES["fertilite_sol"]),
    )
    niveau_mecanisation = fields.String(
        load_default=DEFAULTS.get("niveau_mecanisation"),
        allow_none=True,
        validate=validate.OneOf(ORDRES["niveau_mecanisation"]),
    )
    annees_experience_culture = fields.String(
        load_default=DEFAULTS.get("annees_experience_culture"),
        allow_none=True,
        validate=validate.OneOf(ORDRES["annees_experience_culture"]),
    )


class HistoriqueRendementSchema(Schema):
    """Valide les paramètres de requête de GET /api/rendement/historique."""

    culture_id = fields.Integer(
        required=False, 
        load_default=None, 
        allow_none=True,
        validate=validate.Range(min=1)
    )


predire_rendement_schema = PredireRendementSchema()
historique_rendement_schema = HistoriqueRendementSchema()
