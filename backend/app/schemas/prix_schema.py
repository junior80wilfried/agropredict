"""Schémas de validation pour les routes de prix/marché."""

from marshmallow import Schema, fields, validate


class PrixCultureQuerySchema(Schema):
    """Valide les paramètres de requête de GET /api/prix/<culture_id>."""

    marche_id = fields.Integer(required=False, load_default=None, allow_none=True,
                                validate=validate.Range(min=1))


class MarchesProchesQuerySchema(Schema):
    """Valide les paramètres de requête de GET /api/prix/<culture_id>/marches."""

    ville = fields.String(required=False, load_default=None, allow_none=True,
                           validate=validate.Length(max=120))


prix_culture_query_schema = PrixCultureQuerySchema()
marches_proches_query_schema = MarchesProchesQuerySchema()
