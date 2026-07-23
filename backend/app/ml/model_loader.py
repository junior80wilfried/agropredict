"""Chargement paresseux et mis en cache des modèles pré-entraînés
(modele_prix.joblib, modele_rendement.joblib).

Charger un Random Forest à 300 arbres depuis le disque prend plusieurs
centaines de ms : on ne veut le faire qu'une seule fois par process (au
premier appel), pas à chaque requête HTTP.
"""
from __future__ import annotations

import os
import joblib

_ML_DIR = os.path.dirname(os.path.abspath(__file__))

_cache: dict[str, object] = {}


def _charger(nom_fichier: str):
    if nom_fichier not in _cache:
        chemin = os.path.join(_ML_DIR, nom_fichier)
        _cache[nom_fichier] = joblib.load(chemin)
    return _cache[nom_fichier]


def get_modele_prix():
    """Pipeline scikit-learn : prédit 'Prix de vente moyen obtenu (en FCFA/kg)'."""
    return _charger("modele_prix.joblib")


def get_modele_rendement():
    """Pipeline scikit-learn : prédit 'Rendement estimé (en kg/ha)'."""
    return _charger("modele_rendement.joblib")
