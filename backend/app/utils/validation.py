"""Utilitaires partagés pour la validation des requêtes (marshmallow)."""

from flask import jsonify
from marshmallow import ValidationError


def reponse_erreur_validation(exc: ValidationError):
    """Transforme une ValidationError marshmallow en réponse JSON 400 lisible.

    Retourne TOUTES les erreurs de validation, pas seulement la première.
    Cela permet à l'utilisateur de corriger toutes les erreurs en une seule fois.

    Utilisé par toutes les routes qui valident request.get_json() ou
    request.args via un schéma marshmallow, pour un format d'erreur cohérent
    dans toute l'API.
    """
    erreurs = []
    for champ, details in exc.messages.items():
        if isinstance(details, list):
            for msg in details:
                erreurs.append(f"{champ}: {msg}")
        else:
            erreurs.append(f"{champ}: {str(details)}")

    return jsonify({
        "erreur": "Données invalides",
        "details": erreurs
    }), 400


def reponse_erreur_authentification(message: str, status_code: int = 401):
    """Retourne une réponse d'erreur standardisée pour les problèmes d'authentification."""
    return jsonify({"erreur": message}), status_code


def reponse_erreur_autorisation(message: str = "Accès interdit.", status_code: int = 403):
    """Retourne une réponse d'erreur standardisée pour les problèmes d'autorisation."""
    return jsonify({"erreur": message}), status_code


def reponse_erreur_ressource_introuvable(message: str = "Ressource introuvable.", status_code: int = 404):
    """Retourne une réponse d'erreur standardisée pour les ressources introuvables."""
    return jsonify({"erreur": message}), status_code
