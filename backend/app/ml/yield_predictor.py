"""Prédiction de rendement (kg/ha) — Random Forest pré-entraîné.

Charge modele_rendement.joblib (entraîné sur 1809 campagnes réelles du
dataset AgroPredict, R² ≈ 0.875 sur le jeu de test) et l'applique au profil
de campagne fourni par l'agriculteur.
"""
from __future__ import annotations

from app.ml.features import construire_dataframe
from app.ml.model_loader import get_modele_rendement


def predict_yield(donnees: dict) -> float:
    """`donnees` : dict de champs API (snake_case, voir app/ml/features.py).
    Retourne le rendement estimé en kg/ha (toujours positif).
    """
    try:
        modele = get_modele_rendement()
        X = construire_dataframe(donnees)
        prediction = float(modele.predict(X)[0])
        return max(prediction, 0.0)
    except Exception as e:
        raise RuntimeError(f"Erreur lors de la prédiction de rendement: {str(e)}")
