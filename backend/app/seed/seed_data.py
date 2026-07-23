"""Jeu de données de démarrage (bootstrap) pour AgroSense — Cameroun.

Ce script peuple la base avec :
  - le référentiel des 17 cultures du dataset AgroPredict (celui utilisé pour
    entraîner modele_prix.joblib et modele_rendement.joblib — voir
    app/ml/features.py), avec rendement/prix de référence = moyennes
    observées dans le dataset, et sol/saison dominants par culture
  - des marchés camerounais (Yaoundé, Douala)
  - 6 mois d'historique de prix simulé (marche aléatoire réaliste, en
    FCFA/kg, autour du prix moyen réel de chaque culture) pour l'écran
    "tendance de marché"
  - un utilisateur de démonstration avec quelques parcelles
  - quelques alertes

⚠️ Ces prix de marché (PrixRecord) restent simulés — seuls les modèles ML
(prix par campagne, rendement) sont entraînés sur les vraies données
AgroPredict. Il faudra remplacer cet historique par les relevés réels de
marché avant mise en production.

Utilisation : flask seed
"""
from __future__ import annotations

import random
from datetime import date, timedelta

from app.extensions import db
from app.models.user import User
from app.models.culture import Culture
from app.models.marche import Marche
from app.models.prix import PrixRecord
from app.models.parcelle import Parcelle
from app.models.alerte import Alerte

# nom, emoji, categorie_agronomique (= "Type / Catégorie de la culture" exact
# du dataset ML), couleur, rendement_ref_kg_ha (moyenne dataset), cycle_jours
# (estimation agronomique générale), sols_favorables (sol dominant dataset),
# saison_favorable (saison dominante dataset), tolérance sécheresse
CULTURES = [
    ("Arachide", "Légumineuse", "#B8860B", 1175, 100, "Argileux (lourd, retient l'eau)", "Grande saison des pluies", False),
    ("Bananier-plantain", "Fruit annuel / Herbacée / Liane", "#D4A017", 9891, 365, "Ferralitique / latéritique (sol rouge)", "Grande saison des pluies", False),
    ("Cotonnier", "Culture industrielle / Rente annuelle", "#6B4A2F", 1023, 180, "Ferralitique / latéritique (sol rouge)", "Grande saison des pluies", True),
    ("Gombo", "Légume / Maraîchage", "#7A4510", 7981, 70, "Argileux (lourd, retient l'eau)", "Grande saison des pluies", True),
    ("Haricot", "Légumineuse", "#5C8A3C", 1357, 90, "Ferralitique / latéritique (sol rouge)", "Grande saison des pluies", False),
    ("Igname", "Tubercule", "#8B5E2A", 8891, 270, "Ferralitique / latéritique (sol rouge)", "Grande saison des pluies", False),
    ("Macabo", "Tubercule", "#9C6B30", 17917, 270, "Sableux (léger, sèche vite)", "Grande saison des pluies", False),
    ("Manioc", "Tubercule", "#C8892A", 11064, 300, "Ferralitique / latéritique (sol rouge)", "Grande saison des pluies", True),
    ("Maïs","Céréale", "#2E6B28", 2319, 100, "Sableux (léger, sèche vite)", "Grande saison des pluies", False),
    ("Mil","Céréale", "#A0782A", 847, 100, "Ferralitique / latéritique (sol rouge)", "Grande saison des pluies", True),
    ("Patate douce", "Tubercule", "#C1622A", 14155, 120, "Sableux (léger, sèche vite)", "Grande saison des pluies", True),
    ("Pomme de terre","Tubercule", "#8A6D3B", 14582, 100, "Limoneux (équilibré)", "Saison sèche (avec irrigation)", False),
    ("Riz","Céréale", "#3A7CA5", 3011, 130, "Ferralitique / latéritique (sol rouge)", "Grande saison des pluies", False),
    ("Soja","Légumineuse", "#6E8B3D", 1613, 100, "Limoneux (équilibré)", "Grande saison des pluies", False),
    ("Sorgho","Céréale", "#A05C1A", 1853, 120, "Limoneux (équilibré)", "Petite saison des pluies", True),
    ("Taro", "Tubercule", "#7A5230", 8134, 270, "Sableux (léger, sèche vite)", "Grande saison des pluies", False),
    ("Tomate", "Légume / Maraîchage", "#C0392B", 15937, 90, "Ferralitique / latéritique (sol rouge)", "Saison sèche (avec irrigation)", False),
]

MARCHES = [
    ("Marché Central", "Yaoundé", "Centre", 3.8667, 11.5167),
    ("Marché Mokolo", "Yaoundé", "Centre", 3.8833, 11.5167),
    ("Marché Mfoundi", "Yaoundé", "Centre", 3.8480, 11.5021),
    ("Marché Sandaga", "Douala", "Littoral", 4.0500, 9.7000),
    ("Marché Mboppi", "Douala", "Littoral", 4.0483, 9.7043),
]

ALERTES = [
    ( "Prix du maïs en hausse", "Bon moment pour vendre — marché de Yaoundé favorable", "succes", "#2E6B28"),
    ( "Pluies annoncées cette semaine", "Conditions idéales pour la plantation du manioc", "info", "#C8892A"),
    ( "Stock de semences limité", "Approvisionnez-vous avant la fin du mois", "alerte", "#A05C1A"),
]

# Prix moyen réel observé dans le dataset AgroPredict (FCFA/kg), utilisé
# comme base pour générer un historique de marché simulé plausible.
PRIX_BASE_FCFA_KG = {
    "Arachide": 649, "Bananier-plantain": 239, "Cotonnier": 281, "Gombo": 405,
    "Haricot": 757, "Igname": 713, "Macabo": 285, "Manioc": 270, "Maïs": 189,
    "Mil": 158, "Patate douce": 231, "Pomme de terre": 458, "Riz": 262,
    "Soja": 142, "Sorgho": 159, "Taro": 286, "Tomate": 355,
}


def _generer_historique_prix(prix_base: float, jours: int = 180) -> list[float]:
    """Marche aléatoire réaliste avec légère tendance et bruit hebdomadaire."""
    valeurs = [prix_base]
    tendance = random.uniform(-0.05, 0.15)  # tendance douce sur la période
    for i in range(1, jours):
        bruit = random.uniform(-0.02, 0.02)
        saison = 0.03 * random.choice([-1, 1]) if i % 30 == 0 else 0
        variation = (tendance / jours) + bruit + saison
        valeurs.append(max(valeurs[-1] * (1 + variation), prix_base * 0.5))
    return valeurs


def seed_all():
    print("→ Suppression des données existantes...")
    PrixRecord.query.delete()
    Parcelle.query.delete()
    Alerte.query.delete()
    Culture.query.delete()
    Marche.query.delete()
    db.session.commit()

    print("→ Insertion des cultures...")
    cultures = {}
    for nom, cat, couleur, rendement, cycle, sols, saison, secheresse in CULTURES:
        culture = Culture(
            nom=nom, categorie_agronomique=cat, couleur=couleur,
            rendement_reference_kg_ha=rendement, cycle_jours=cycle,
            sols_favorables=sols, saison_favorable=saison, tolerance_secheresse=secheresse,
        )
        db.session.add(culture)
        cultures[nom] = culture
    db.session.commit()

    print("→ Insertion des marchés...")
    marches = []
    for nom, ville, region, lat, lon in MARCHES:
        marche = Marche(nom=nom, ville=ville, region=region, latitude=lat, longitude=lon)
        db.session.add(marche)
        marches.append(marche)
    db.session.commit()

    print("→ Génération de 6 mois d'historique de prix (FCFA/kg)...")
    aujourdhui = date.today()
    jours = 180
    for nom, culture in cultures.items():
        for marche in marches:
            serie = _generer_historique_prix(PRIX_BASE_FCFA_KG[nom], jours)
            for i in range(0, jours, 7):  # un relevé hebdomadaire
                d = aujourdhui - timedelta(days=jours - i)
                db.session.add(PrixRecord(
                    culture_id=culture.id, marche_id=marche.id,
                    date=d, prix_fcfa_kg=round(serie[i], 1),
                ))
    db.session.commit()

    print("→ Création d'un utilisateur de démonstration...")
    demo = User(
        nom="Kofi Mensah", email="demo@agrosense.cm", ville="Yaoundé",
        region="Centre", telephone="+237600000000", agriculteur_depuis=2015,
    )
    demo.set_password("demo1234")
    db.session.add(demo)
    db.session.commit()

    parcelles_demo = [
        (cultures["Maïs"], 2.5, "Sableux (léger, sèche vite)", "En croissance"),
        (cultures["Manioc"], 1.5, "Ferralitique / latéritique (sol rouge)", "Planté"),
        (cultures["Gombo"], 0.5, "Argileux (lourd, retient l'eau)", "Récolte prochaine"),
    ]
    for culture, superficie, sol, statut in parcelles_demo:
        db.session.add(Parcelle(
            user_id=demo.id, culture_id=culture.id, superficie_ha=superficie,
            type_sol=sol, statut=statut, date_plantation=date.today() - timedelta(days=60),
        ))
    db.session.commit()

    print("→ Insertion des alertes...")
    for emoji, titre, message, type_, couleur in ALERTES:
        db.session.add(Alerte(emoji=emoji, titre=titre, message=message, type=type_, couleur=couleur))
    db.session.commit()

    print("✓ Seed terminé. Compte de démo : demo@agrosense.cm / demo1234")
