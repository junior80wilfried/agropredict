from __future__ import annotations

"""Moteur de recommandation de cultures (écran "Cultures" de l'app mobile).

Pour chaque culture du référentiel, prédit rendement et prix avec les deux
modèles ML pré-entraînés (mêmes conditions de parcelle pour toutes les
cultures candidates), puis calcule le revenu potentiel :

    revenu_potentiel_fcfa = rendement_estime_kg_ha x prix_estime_fcfa_kg x superficie_ha

Les cultures sont classées par revenu potentiel décroissant. C'est la même
logique que recommander_cultures() dans le notebook d'entraînement
(Untitled9.ipynb), avec un raffinement : ici, "Type / Catégorie de la
culture" est déduit de la culture candidate elle-même (Culture.categorie_agronomique),
pas fixé à une valeur unique pour toutes les cultures — chaque culture est
donc évaluée avec sa vraie catégorie agronomique.

Remplace l'ancienne formule pondérée (sol/saison/tendance de prix/rentabilité
approximative), qui ne s'appuyait pas sur les modèles ML.
"""

from app.ml.features import ALL_FIELDS
from app.ml.predicteur import predire_campagne
from app.models.culture import Culture


def _label_rentabilite(score: float) -> str:
    if score >= 85:
        return "Très élevé"
    if score >= 60:
        return "Élevé"
    if score >= 35:
        return "Moyen"
    return "Faible"


def recommander_cultures(conditions: dict, limite: int = 6) -> list[dict]:
    """`conditions` : dict de champs API (snake_case, voir app/ml/features.py),
    typiquement type_sol/saison/region/superficie_ha renseignés par
    l'utilisateur ; le reste prend des valeurs par défaut. Ne doit PAS
    contenir 'culture' ni 'type_culture' (dérivés par culture candidate).
    """
    conditions_communes = {
        champ: valeur for champ, valeur in conditions.items()
        if champ in ALL_FIELDS and champ not in ("culture", "type_culture") and valeur is not None
    }
    superficie_ha = conditions_communes.get("superficie_ha", 1.0)

    cultures = Culture.query.all()
    resultats = []

    for culture in cultures:
        profil = {
            **conditions_communes,
            "culture": culture.nom,
            "type_culture": culture.categorie_agronomique,
        }
        prediction = predire_campagne(profil)

        sols_favorables = [s.strip() for s in culture.sols_favorables.split(",")]
        type_sol_demande = conditions_communes.get("type_sol")
        saison_demandee = conditions_communes.get("saison")

        tags = []
        if type_sol_demande and type_sol_demande in sols_favorables:
            tags.append("Sol adapté")
        if saison_demandee and culture.saison_favorable == saison_demandee:
            tags.append("Saison favorable")
        if culture.tolerance_secheresse:
            tags.append("Résistant sécheresse")

        resultats.append({
            "culture": culture.to_dict(),
            "rendement_estime_kg_ha": prediction["rendement_estime_kg_ha"],
            "prix_estime_fcfa_kg": prediction["prix_estime_fcfa_kg"],
            "revenu_potentiel_fcfa": prediction["revenu_estime_fcfa"],
            "tags": tags or ["Culture polyvalente"],
        })

    resultats.sort(key=lambda r: r["revenu_potentiel_fcfa"], reverse=True)
    resultats = resultats[:limite]

    revenu_max = max((r["revenu_potentiel_fcfa"] for r in resultats), default=1) or 1
    for r in resultats:
        score = round(100 * r["revenu_potentiel_fcfa"] / revenu_max)
        r["score"] = int(score)
        r["rentabilite"] = _label_rentabilite(score)

    return resultats
