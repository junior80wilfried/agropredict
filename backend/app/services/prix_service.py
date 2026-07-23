from __future__ import annotations

from datetime import date, timedelta

from app.models.culture import Culture
from app.models.marche import Marche
from app.models.prix import PrixRecord


def historique_prix(culture_id: int, marche_id: int | None = None, jours: int = 180) -> list[dict]:
    query = PrixRecord.query.filter(
        PrixRecord.culture_id == culture_id,
        PrixRecord.date >= date.today() - timedelta(days=jours),
    )
    if marche_id:
        query = query.filter(PrixRecord.marche_id == marche_id)

    records = query.order_by(PrixRecord.date.asc()).all()
    # Si plusieurs marchés, on agrège par date (moyenne) pour obtenir une
    # seule série exploitable par le modèle.
    par_date: dict[str, list[float]] = {}
    for r in records:
        par_date.setdefault(r.date.isoformat(), []).append(r.prix_fcfa_kg)

    return [
        {"date": d, "prix_fcfa_kg": sum(v) / len(v)}
        for d, v in sorted(par_date.items())
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
