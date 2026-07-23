"""Chargement paresseux et mis en cache des modèles pré-entraînés
(modele_prix.joblib, modele_rendement.joblib).

Charger un Random Forest à 300 arbres depuis le disque prend plusieurs
centaines de ms : on ne veut le faire qu'une seule fois par process (au
premier appel), pas à chaque requête HTTP.

Sécurité : vérification des checksums pour détecter les modifications
non autorisées des fichiers de modèles.
"""
from __future__ import annotations

import os
import hashlib
import joblib
from threading import Lock

_ML_DIR = os.path.dirname(os.path.abspath(__file__))

_cache: dict[str, object] = {}
_cache_lock = Lock()

# Checksums SHA256 des modèles (à générer avec : sha256sum modele_*.joblib)
# Remplacez ces valeurs par les checksums réels de vos fichiers
MODEL_CHECKSUMS = {
    "modele_prix.joblib": None,  # Remplacez par le vrai checksum
    "modele_rendement.joblib": None,  # Remplacez par le vrai checksum
}


def _calculer_checksum(fichier: str) -> str:
    """Calcule le checksum SHA256 d'un fichier."""
    sha256 = hashlib.sha256()
    with open(fichier, 'rb') as f:
        while True:
            data = f.read(65536)  # Lire par blocs de 64 Ko
            if not data:
                break
            sha256.update(data)
    return sha256.hexdigest()


def _verifier_checksum(nom_fichier: str, chemin: str) -> bool:
    """Vérifie le checksum d'un modèle."""
    expected_checksum = MODEL_CHECKSUMS.get(nom_fichier)
    if expected_checksum is None:
        # Si aucun checksum n'est configuré, on saute la vérification
        # (mais on affiche un avertissement en développement)
        import warnings
        warnings.warn(
            f"Aucun checksum configuré pour {nom_fichier}. "
            "Pour la production, configurez MODEL_CHECKSUMS dans model_loader.py.",
            UserWarning
        )
        return True
    
    actual_checksum = _calculer_checksum(chemin)
    return actual_checksum == expected_checksum


def _charger(nom_fichier: str):
    """Charge un modèle depuis le disque avec vérification de checksum."""
    if nom_fichier not in _cache:
        with _cache_lock:
            if nom_fichier not in _cache:  # Double-check locking
                chemin = os.path.join(_ML_DIR, nom_fichier)
                
                # Vérifier que le fichier existe
                if not os.path.exists(chemin):
                    raise FileNotFoundError(
                        f"Modèle {nom_fichier} introuvable dans {_ML_DIR}. "
                        "Vérifiez que les fichiers de modèles sont présents."
                    )
                
                # Vérifier le checksum
                if not _verifier_checksum(nom_fichier, chemin):
                    raise RuntimeError(
                        f"Checksum du modèle {nom_fichier} invalide. "
                        "Le fichier a peut-être été modifié ou corrompu."
                    )
                
                _cache[nom_fichier] = joblib.load(chemin)
    return _cache[nom_fichier]


def get_modele_prix():
    """Pipeline scikit-learn : prédit 'Prix de vente moyen obtenu (en FCFA/kg)'."""
    return _charger("modele_prix.joblib")


def get_modele_rendement():
    """Pipeline scikit-learn : prédit 'Rendement estimé (en kg/ha)'."""
    return _charger("modele_rendement.joblib")
