from __future__ import annotations

from datetime import date, timedelta
from sqlalchemy import func

from app.extensions import db
from app.models.culture import Culture
from app.models.marche import Marche
from app.models.prix import PrixRecord


def historique_prix(culture_id: int, marche_id: int | None = None, jours: int = 180) -> list[dict]:
    """Récupère l'historique des prix pour une culture, éventuellement filtré par marché.
    
    Utilise une agrégation SQL pour éviter de charger toutes les données en mémoire.
    """
    query = db.session.query(
        PrixRecord.date,
        func.avg(PrixRecord.prix_fcfa_kg).label('avg_prix')
    ).filter(
        PrixRecord.culture_id == culture_id,
        PrixRecord.date >= date.today() - timedelta(days=jours),
    ).group_by(PrixRecord.date)
    
    if marche_id:
        query = query.filter(PrixRecord.marche_id == marche_id)

    query = query.order_by(PrixRecord.date.asc())
    records = query.all()

    return [
        {"date": r.date.isoformat(), "prix_fcfa_kg": round(r.avg_prix, 1)}
        for r in records
    ]


def resume_prix(culture: Culture, marche_id: int | None = None) -> dict:
    """Tendance réelle du marché (historique PrixRecord) pour une culture.

    Ne contient plus de prédiction : la prédiction de prix se fait désormais
    via POST /api/rendement/predire, à partir du profil complet de campagne
    (modele_prix.joblib), et non plus d'un historique de série temporelle.
    """
    historique = historique_prix(culture.id, marche_id)
    if not historique:
        return {
            "culture": culture.to_dict(),
            "historique": [],
            "prix_actuel": None,
            "variation_pct": None,
        }

    prix_actuel = historique[-1]["prix_fcfa_kg"]
    prix_precedent = historique[-2]["prix_fcfa_kg"] if len(historique) > 1 else prix_actuel
    variation_pct = (
        round((prix_actuel - prix_precedent) / prix_precedent * 100, 1)
        if prix_precedent else 0.0
    )

    return {
        "culture": culture.to_dict(),
        "historique": historique[-26:],  # ~6 mois si relevés hebdomadaires
        "prix_actuel": round(prix_actuel, 1),
        "variation_pct": variation_pct,
        "en_hausse": prix_actuel >= prix_precedent,
    }


def marches_proches(culture_id: int, ville: str | None = None) -> list[dict]:
    """Récupère les marchés proches avec leur prix actuel pour une culture."""
    query = Marche.query
    if ville:
        query = query.filter(Marche.ville == ville)
    marches = query.limit(5).all()

    resultat = []
    for marche in marches:
        historique = historique_prix(culture_id, marche.id, jours=14)
        prix = historique[-1]["prix_fcfa_kg"] if historique else None
        resultat.append({**marche.to_dict(), "prix_fcfa_kg": round(prix, 1) if prix else None})
    return resultat
