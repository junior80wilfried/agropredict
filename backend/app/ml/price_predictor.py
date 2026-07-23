"""Prédiction de prix de vente (FCFA/kg) — Random Forest pré-entraîné.

Charge modele_prix.joblib (entraîné sur 1809 campagnes réelles du dataset
AgroPredict, R² ≈ 0.775 sur le jeu de test) et l'applique au profil de
campagne fourni par l'agriculteur.

Contrairement à l'ancienne architecture (Prophet sur historique de marché),
ce modèle prédit le prix de vente moyen attendu POUR une campagne donnée
(culture + conditions de production), pas une tendance de marché datée.
"""
from __future__ import annotations

from app.ml.features import construire_dataframe
from app.ml.model_loader import get_modele_prix


def predict_price(donnees: dict) -> float:
    """`donnees` : dict de champs API (snake_case, voir app/ml/features.py).
    Retourne le prix de vente moyen estimé en FCFA/kg (toujours positif).
    """
    try:
        modele = get_modele_prix()
        X = construire_dataframe(donnees)
        prediction = float(modele.predict(X)[0])
        return max(prediction, 0.0)
    except Exception as e:
        raise RuntimeError(f"Erreur lors de la prédiction de prix: {str(e)}")
