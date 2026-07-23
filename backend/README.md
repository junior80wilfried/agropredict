# AgroSense — Backend Flask

API REST pour l'application mobile AgroSense (prédiction de prix, de
rendement, et recommandation de cultures pour les agriculteurs camerounais).

## Stack

- **Flask 3** (application factory) + **Flask-SQLAlchemy** (PostgreSQL)
- **Flask-JWT-Extended** pour l'authentification par token
- **Flask-Migrate** pour les migrations de schéma
- **2 modèles Random Forest pré-entraînés** (scikit-learn, voir `app/ml/`) :
  `modele_rendement.joblib` (R² ≈ 0.875) et `modele_prix.joblib` (R² ≈ 0.775),
  entraînés sur les 1809 campagnes réelles du dataset AgroPredict (23
  caractéristiques : culture, sol, saison, engrais, mécanisation, etc. — voir
  `app/ml/features.py`). Chargés une fois au démarrage, pas ré-entraînés à
  la volée.

## Installation

```bash
cd backend
python3 -m venv venv
source venv/bin/activate          # Windows : venv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env              # puis éditez .env (SECRET_KEY, DATABASE_URL...)
```

Créez la base PostgreSQL :

```sql
CREATE DATABASE agrosense_db;
CREATE USER agrosense_user WITH PASSWORD 'agrosense_pass';
GRANT ALL PRIVILEGES ON DATABASE agrosense_db TO agrosense_user;
```

Puis initialisez le schéma et les données de démonstration :

```bash
export FLASK_APP=run.py
flask db init && flask db migrate -m "init" && flask db upgrade
# ou plus simple pour démarrer rapidement, sans migrations versionnées :
python3 -c "from app import create_app; from app.extensions import db; app=create_app(); app.app_context().push(); db.create_all()"

flask seed          # peuple cultures, marchés, 6 mois de prix, alertes, compte démo
```

Lancement :

```bash
flask run --host=0.0.0.0 --port=5000
# ou : python run.py
```

Compte de démonstration créé par `flask seed` :
`demo@agrosense.cm` / `demo1234`

## Endpoints principaux

| Méthode | Route                              | Description                              |
|---------|-------------------------------------|-------------------------------------------|
| POST    | `/api/auth/inscription`            | Créer un compte                           |
| POST    | `/api/auth/connexion`              | Connexion → token JWT                     |
| GET     | `/api/auth/moi`                    | Profil de l'utilisateur connecté          |
| GET     | `/api/cultures`                    | Référentiel des cultures                  |
| GET     | `/api/cultures/recommandations`    | Cultures triées par revenu potentiel (ML) |
| GET     | `/api/prix/<culture_id>`           | Historique réel du marché (sans prédiction) |
| GET     | `/api/prix/<culture_id>/marches`   | Marchés proches et leurs prix             |
| GET     | `/api/rendement/champs`            | Valeurs valides par champ (listes déroulantes) |
| POST    | `/api/rendement/predire`           | Rendement + prix + revenu estimés (ML)    |
| GET     | `/api/rendement/historique`        | Historique des prédictions de l'utilisateur |
| GET     | `/api/profil`                      | Profil, stats, "mes cultures", résumé     |
| POST    | `/api/profil/parcelles`            | Ajouter une culture suivie                |
| GET     | `/api/alertes`                     | Alertes actives                           |

Toutes les routes (sauf inscription/connexion) nécessitent l'en-tête
`Authorization: Bearer <token>`.

## Note sur les données ML

Les prix de démonstration (`flask seed`) pour l'écran "tendance de marché"
(`PrixRecord`) restent **simulés** (marche aléatoire réaliste, calée sur le
prix moyen réel de chaque culture) — ils servent uniquement à afficher un
historique de marché plausible, pas à entraîner de modèle. Les deux modèles
de prédiction (`app/ml/modele_rendement.joblib`, `app/ml/modele_prix.joblib`)
sont eux entraînés hors-ligne sur le vrai dataset AgroPredict (voir le
notebook d'entraînement) et chargés tels quels ; ils ne sont jamais
ré-entraînés par le backend.

⚠️ Les modèles ont été sauvegardés avec **scikit-learn 1.6.1** : gardez
`requirements.txt` aligné sur cette version pour éviter tout problème de
désérialisation.

⚠️ **Migration de base de données requise** : ce travail d'intégration a
modifié `RendementPrediction` (nouveaux champs `profil` JSON, `prix_estime_fcfa_kg`)
et `Alerte` (nouveau champ `emoji`). Après avoir tiré ces changements sur un
environnement avec une vraie base Postgres, exécutez :
```bash
flask db migrate -m "modeles ml pre-entraines : profil rendement/prix, emoji alerte"
flask db upgrade
```
