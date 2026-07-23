from __future__ import annotations

from datetime import datetime, timezone

from app.extensions import db
from app.ml.features import ALL_FIELDS
from app.ml.predicteur import predire_campagne
from app.models.culture import Culture
from app.models.rendement import RendementPrediction


class RendementError(Exception):
    def __init__(self, message: str, status_code: int = 400):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


def calculer_rendement(user_id: int, data: dict) -> RendementPrediction:
    """`data` doit déjà avoir été validé par PredireRendementSchema (routes/rendement.py).

    'culture' et 'type_culture' (2 des 23 caractéristiques attendues par les
    modèles ML) ne sont pas dans `data` : ce sont des propriétés de la
    culture elle-même, pas de la campagne du fermier, donc on les déduit ici
    depuis la table Culture plutôt que de les redemander à l'utilisateur.
    """
    culture = Culture.query.get(data["culture_id"])
    if not culture:
        raise RendementError("Culture introuvable.", 404)

    profil_campagne = {
        champ: data[champ] for champ in ALL_FIELDS if champ in data
    }
    profil_campagne["culture"] = culture.nom
    profil_campagne["type_culture"] = culture.categorie_agronomique

    try:
        resultat = predire_campagne(profil_campagne)
    except Exception as e:
        # Loguer l'erreur pour le débogage
        db.current_app.logger.error(f"Erreur lors de la prédiction de rendement: {str(e)}")
        raise RendementError("Une erreur est survenue lors de la prédiction. Veuillez réessayer.", 500)

    prediction = RendementPrediction(
        user_id=user_id,
        culture_id=culture.id,
        superficie_ha=data["superficie_ha"],
        profil=profil_campagne,
        rendement_estime_kg_ha=resultat["rendement_estime_kg_ha"],
        prix_estime_fcfa_kg=resultat["prix_estime_fcfa_kg"],
        production_totale_kg=resultat["production_totale_kg"],
        revenu_estime_fcfa=resultat["revenu_estime_fcfa"],
        created_at=datetime.now(timezone.utc),
    )
    db.session.add(prediction)
    db.session.commit()

    return prediction


def historique_rendements(user_id: int, culture_id: int | None = None) -> list[RendementPrediction]:
    """Récupère l'historique des prédictions de rendement pour un utilisateur."""
    query = RendementPrediction.query.filter_by(user_id=user_id)
    if culture_id:
        query = query.filter_by(culture_id=culture_id)
    return query.order_by(RendementPrediction.created_at.desc()).all()
