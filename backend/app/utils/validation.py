"""Utilitaires partagés pour la validation des requêtes (marshmallow)."""

from flask import jsonify
from marshmallow import ValidationError


def reponse_erreur_validation(exc: ValidationError):
    """Transforme une ValidationError marshmallow en réponse JSON 400 lisible.

    Utilisé par toutes les routes qui valident request.get_json() ou
    request.args via un schéma marshmallow, pour un format d'erreur cohérent
    dans toute l'API.
    """
    premier_champ = next(iter(exc.messages))
    details = exc.messages[premier_champ]
    message = details[0] if isinstance(details, list) else str(details)
    return jsonify({"erreur": f"{premier_champ}: {message}"}), 400
