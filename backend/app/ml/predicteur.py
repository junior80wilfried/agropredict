"""Prédiction combinée rendement + prix, pour un même profil de campagne.

Remplace l'ancienne fusion.py (fusion pondérée Prophet/Random Forest, basée
sur un historique de prix de marché). Les deux nouveaux modèles pré-entraînés
partagent exactement les mêmes 23 caractéristiques d'entrée : on les appelle
donc ensemble et on dérive le revenu estimé de leurs deux sorties.
"""
from __future__ import annotations

from app.ml.price_predictor import predict_price
from app.ml.yield_predictor import predict_yield


def predire_campagne(donnees: dict) -> dict:
    """`donnees` : dict de champs API (snake_case, voir app/ml/features.py),
    doit au minimum contenir 'culture' (les autres champs sont complétés
    avec des valeurs par défaut si absents).

    Retourne rendement (kg/ha), prix (FCFA/kg), et le revenu qui en découle
    pour la superficie renseignée.
    """
    try:
        rendement_kg_ha = predict_yield(donnees)
        prix_fcfa_kg = predict_price(donnees)
    except Exception as e:
        raise RuntimeError(f"Erreur lors de la prédiction ML: {str(e)}")

    superficie_ha = donnees.get("superficie_ha") or 1.0
    production_totale_kg = rendement_kg_ha * superficie_ha
    revenu_estime_fcfa = production_totale_kg * prix_fcfa_kg

    return {
        "rendement_estime_kg_ha": round(rendement_kg_ha, 1),
        "prix_estime_fcfa_kg": round(prix_fcfa_kg, 1),
        "production_totale_kg": round(production_totale_kg, 1),
        "revenu_estime_fcfa": round(revenu_estime_fcfa, 0),
    }
