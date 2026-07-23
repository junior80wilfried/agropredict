"""Référentiel unique des caractéristiques (features) utilisées par les
modèles ML pré-entraînés d'AgroPredict (modele_prix.joblib, modele_rendement.joblib).

Ce module est la SEULE source de vérité pour :
  - la correspondance entre les noms de champs API (snake_case, utilisés dans
    le JSON envoyé par l'app mobile) et les noms de colonnes exacts attendus
    par les pipelines scikit-learn (noms français issus du formulaire
    Google Form AgroPredict — ne JAMAIS les modifier, ce sont ceux vus à
    l'entraînement) ;
  - les valeurs valides pour chaque champ catégoriel (nominal ou ordinal) ;
  - le mapping ordinal explicite (même ordre que le notebook d'entraînement
    Untitled9.ipynb — toute modification ici désynchronise les modèles) ;
  - des valeurs par défaut raisonnables (mode/médiane du dataset
    d'entraînement), utilisées quand un champ optionnel n'est pas fourni
    (ex. moteur de recommandation, qui ne fait varier que quelques champs).

Il est importé à la fois par les schémas de validation (marshmallow) et par
les prédicteurs (app/ml/yield_predictor.py, app/ml/price_predictor.py), afin
qu'il n'y ait qu'un seul endroit à mettre à jour si le dataset ou les modèles
évoluent.
"""
from __future__ import annotations

import pandas as pd

# ============================================================
# 1. CORRESPONDANCE CHAMP API (snake_case) -> COLONNE D'ENTRAÎNEMENT
# ============================================================
# ⚠️ Les valeurs de ce dict (à droite) doivent être identiques, caractère
# pour caractère, aux noms de colonnes du CSV d'entraînement.

FIELD_TO_COLUMN: dict[str, str] = {
    # --- Nominales (16) ---
    "culture": "Culture",
    "type_culture": "Type / Catégorie de la culture",
    "variete_semence": "Type de semence / variété utilisée",
    "mode_mise_en_terre": "Mode de mise en terre",
    "region": "Région administrative",
    "zone_agro_ecologique": "Zone agro-écologique",
    "saison": "Saison de culture",
    "type_sol": "Type de sol (tel que perçu)",
    "mode_approvisionnement_eau": "Mode d'approvisionnement en eau",
    "traitement_phytosanitaire": "Traitement phytosanitaire (pesticides, herbicides…)",
    "systeme_culture": "Système de culture",
    "rotation_culturale": "Rotation culturale pratiquée ?",
    "mois_mise_en_terre": "Mois de mise en terre (semis / plantation)",
    "utilisation_engrais": "Utilisation d'engrais",
    "type_engrais_mineral": "Type d'engrais minéral utilisé (cochez tout ce qui s'applique)",
    "accompagnement_technique": "Avez-vous reçu un accompagnement technique pendant cette campagne ?",
    # --- Ordinales (5) ---
    "altitude": "Altitude approximative du champ",
    "pluviometrie": "Pluviométrie estimée reçue sur le cycle cultural",
    "fertilite_sol": "Fertilité perçue du sol au moment de la mise en culture",
    "niveau_mecanisation": "Niveau de mécanisation",
    "annees_experience_culture": "Depuis combien d'années cultivez-vous cette culture ?",
    # --- Numériques (2) ---
    "superficie_ha": "Superficie totale cultivée (en hectares)",
    "annee_campagne": "Année de la campagne agricole",
}

COLUMN_TO_FIELD: dict[str, str] = {v: k for k, v in FIELD_TO_COLUMN.items()}

NOMINAL_FIELDS = [
    "culture", "type_culture", "variete_semence", "mode_mise_en_terre", "region",
    "zone_agro_ecologique", "saison", "type_sol", "mode_approvisionnement_eau",
    "traitement_phytosanitaire", "systeme_culture", "rotation_culturale",
    "mois_mise_en_terre", "utilisation_engrais", "type_engrais_mineral",
    "accompagnement_technique",
]
ORDINAL_FIELDS = [
    "altitude", "pluviometrie", "fertilite_sol", "niveau_mecanisation",
    "annees_experience_culture",
]
NUMERIC_FIELDS = ["superficie_ha", "annee_campagne"]

ALL_FIELDS = NOMINAL_FIELDS + ORDINAL_FIELDS + NUMERIC_FIELDS

# ============================================================
# 2. MAPPING ORDINAL (identique au notebook d'entraînement — NE PAS MODIFIER
#    l'ordre des listes sans ré-entraîner les modèles)
# ============================================================

ORDRES: dict[str, list[str]] = {
    "altitude": [
        "Moins de 500 m (plaine)",
        "500 – 1 000 m (moyenne altitude)",
        "1 000 – 1 500 m (altitude)",
    ],
    "pluviometrie": [
        "Très faible (moins de 300 mm)",
        "Faible (300 – 600 mm)",
        "Moyenne (600 – 1 000 mm)",
        "Élevée (1 000 – 1 500 mm)",
    ],
    "fertilite_sol": [
        "Appauvri (rendements en baisse)",
        "Moyennement fertile",
        "Fertile (bonne production habituelle)",
        "Très fertile (nouveau défrichage ou jachère longue)",
    ],
    "niveau_mecanisation": [
        "Manuel (machette, houe, daba uniquement)",
        "Semi-mécanisé (traction animale)",
        "Mécanisé (tracteur)",
    ],
    "annees_experience_culture": [
        "Première fois (moins d'1 an)",
        "1 – 3 ans",
        "4 – 7 ans",
        "Plus de 15 ans",
    ],
}

# ============================================================
# 3. VALEURS NOMINALES VALIDES (issues du dataset d'entraînement — le
#    OneHotEncoder gère les valeurs inconnues avec handle_unknown="ignore",
#    mais on valide en amont côté API pour donner un message d'erreur clair)
# ============================================================

VALEURS_NOMINALES: dict[str, list[str]] = {
    "culture": [
        "Arachide", "Bananier-plantain", "Cotonnier", "Gombo", "Haricot", "Igname",
        "Macabo", "Manioc", "Maïs", "Mil", "Patate douce", "Pomme de terre", "Riz",
        "Soja", "Sorgho", "Taro", "Tomate",
    ],
    "type_culture": [
        "Culture industrielle / Rente annuelle", "Céréale",
        "Fruit annuel / Herbacée / Liane", "Légume / Maraîchage", "Légumineuse",
        "Tubercule",
    ],
    "variete_semence": [
        "Ne sait pas", "Variété améliorée certifiée (OAD/IRAD)",
        "Variété locale (traditionnelle)",
    ],
    "mode_mise_en_terre": [
        "Bouturage de tiges / lianes", "Plantation de rejets / œilletons",
        "Plantation de tubercules / fragments", "Repiquage de plants (pépinière)",
        "Semis direct (graines)",
    ],
    "region": [
        "Adamaoua", "Centre", "Est", "Extrême-Nord", "Littoral", "Nord",
        "Nord-Ouest", "Ouest", "Sud", "Sud-Ouest",
    ],
    "zone_agro_ecologique": [
        "Zone de hauts plateaux (Ouest / Nord-Ouest)",
        "Zone forestière humide (Centre / Sud / Est)",
        "Zone soudano-sahélienne (Nord)",
    ],
    "saison": [
        "Grande saison des pluies", "Petite saison des pluies",
        "Saison sèche (avec irrigation)",
    ],
    "type_sol": [
        "Argileux (lourd, retient l'eau)", "Ferralitique / latéritique (sol rouge)",
        "Limoneux (équilibré)", "Sableux (léger, sèche vite)",
    ],
    "mode_approvisionnement_eau": [
        "Irrigation gravitaire (casiers aménagés, type SEMRY)",
        "Irrigation par pompe (motopompe)", "Pluviale stricte (uniquement la pluie)",
    ],
    "traitement_phytosanitaire": [
        "Aucun traitement", "Herbicides + Insecticides / Fongicides",
        "Herbicides uniquement", "Insecticides / Fongicides uniquement",
    ],
    "systeme_culture": [
        "Culture associée (plusieurs espèces mélangées)",
        "Culture pure (une seule espèce)",
    ],
    "rotation_culturale": [
        "Ne sait pas", "Non, même culture qu'avant (monoculture répétée)",
        "Oui, rotation pratiquée", "Première mise en culture de cette parcelle",
    ],
    "mois_mise_en_terre": [
        "Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août",
        "Septembre", "Octobre", "Novembre", "Décembre",
    ],
    "utilisation_engrais": [
        "Aucun engrais", "Engrais minéral / chimique uniquement (NPK, urée…)",
        "Engrais organique uniquement (compost, fumier, fiente)",
        "Les deux (organique + minéral)",
    ],
    "type_engrais_mineral": [
        "Aucun", "KCl (potasse)", "NPK (20-10-10 ou autre)", "Urée (46%N)",
        "NPK (20-10-10 ou autre), Urée (46%N), Autre engrais minéral",
    ],
    "accompagnement_technique": [
        "Non — Aucun accompagnement", "Oui — Autre agriculteur expérimenté",
        "Oui — Coopérative ou groupement", "Oui — ONG ou projet agricole",
        "Oui — Vulgarisateur / Agent MINADER",
    ],
}

# ============================================================
# 4. VALEURS PAR DÉFAUT (mode/médiane du dataset d'entraînement) — utilisées
#    quand un champ optionnel n'est pas fourni par l'appelant (ex. moteur de
#    recommandation, qui ne fait varier que sol/saison/superficie/région)
# ============================================================

DEFAULTS: dict[str, object] = {
    "type_culture": "Tubercule",
    "variete_semence": "Variété locale (traditionnelle)",
    "mode_mise_en_terre": "Semis direct (graines)",
    "region": "Centre",
    "zone_agro_ecologique": "Zone forestière humide (Centre / Sud / Est)",
    "saison": "Grande saison des pluies",
    "type_sol": "Sableux (léger, sèche vite)",
    "mode_approvisionnement_eau": "Pluviale stricte (uniquement la pluie)",
    "traitement_phytosanitaire": "Aucun traitement",
    "systeme_culture": "Culture pure (une seule espèce)",
    "rotation_culturale": "Oui, rotation pratiquée",
    "mois_mise_en_terre": "Mai",
    "utilisation_engrais": "Aucun engrais",
    "type_engrais_mineral": "Aucun",
    "accompagnement_technique": "Non — Aucun accompagnement",
    "altitude": "Moins de 500 m (plaine)",
    "pluviometrie": "Moyenne (600 – 1 000 mm)",
    "fertilite_sol": "Moyennement fertile",
    "niveau_mecanisation": "Manuel (machette, houe, daba uniquement)",
    "annees_experience_culture": "4 – 7 ans",
    "superficie_ha": 1.0,
    "annee_campagne": 2026,
}


# ============================================================
# 5. CONSTRUCTION DU VECTEUR DE FEATURES POUR LES MODÈLES
# ============================================================

def construire_dataframe(donnees: dict) -> pd.DataFrame:
    """Construit le DataFrame à une ligne attendu par les pipelines
    scikit-learn, à partir d'un dict de champs API (snake_case).

    - Les champs manquants sont complétés avec DEFAULTS (sauf 'culture', qui
      doit toujours être fourni explicitement par l'appelant).
    - Les champs ordinaux (str) sont convertis en leur code entier via ORDRES.
    - Les colonnes sont renommées vers les noms exacts d'entraînement.
    """
    ligne: dict[str, object] = {}

    for champ in ALL_FIELDS:
        valeur = donnees.get(champ, DEFAULTS.get(champ))

        if champ in ORDRES:
            mapping = {val: i for i, val in enumerate(ORDRES[champ])}
            valeur = mapping.get(valeur)  # valeur inconnue/"Ne sait pas" -> None -> imputé

        ligne[FIELD_TO_COLUMN[champ]] = valeur

    return pd.DataFrame([ligne])
