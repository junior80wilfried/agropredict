# AgroSense

Application mobile complète pour agriculteurs camerounais : prédiction de
prix, de rendements agricoles, et recommandations de cultures adaptées au
sol et à la saison. Convertie depuis une maquette Figma Make (React/Tailwind)
vers une stack **Flutter (mobile) + Flask (API) + PostgreSQL + ML
(Prophet/Random Forest)**.

```
agrosense/
├── backend/   → API Flask (voir backend/README.md)
└── mobile/    → App Flutter (voir mobile/README.md)
```

## Démarrage rapide

1. **Backend** : installez PostgreSQL, configurez `.env`, puis :
   ```bash
   cd backend
   pip install -r requirements.txt
   flask db upgrade   # ou db.create_all(), voir backend/README.md
   flask seed
   flask run
   ```
2. **Mobile** :
   ```bash
   cd mobile
   flutter pub get
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
   ```
3. Connectez-vous avec `demo@agrosense.cm` / `demo1234`, ou créez un compte.

## Ce qui a changé par rapport à la maquette d'origine

La maquette Figma Make fournie (`Mobile_app_mockup_for_agriculture.zip`)
était un prototype React/Vite statique avec des données fictives (Ghana,
GHS). Cette version :

- **Cible le Cameroun** : villes, régions, marchés et prix en FCFA/kg,
  cohérents avec le projet AgroPredict.
- **Ajoute l'authentification** (inscription/connexion, absente de la
  maquette) avec JWT.
- **Remplace les données statiques par une vraie API Flask** connectée à
  PostgreSQL, avec un module ML pour la prédiction de prix (fusion
  Prophet/Random Forest 60/40) et de rendement (Random Forest).
- **Reconstruit les 5 écrans en Flutter** (Accueil, Prix, Rendements,
  Cultures, Profil) avec une architecture par couches (data/domain
  implicite/presentation) et `flutter_bloc` pour la gestion d'état, en
  conservant la palette de couleurs et l'esprit visuel de la maquette.

## Limites connues / prochaines étapes

- Les prix de démonstration sont **simulés** (`flask seed`) — à remplacer
  par les données réelles collectées via le formulaire AgroPredict.
- Les modèles ML sont ré-entraînés à la volée à chaque requête (pratique
  pour le développement, à optimiser en production : entraînement
  différé + modèles versionnés en `.pkl`).
- Pas encore de mode hors-ligne côté mobile (mentionné comme besoin clé
  dans l'analyse concurrentielle AgroPredict) — prévoir un cache local
  (ex. `sqflite` ou `hive`) dans une itération suivante.
- La météo affichée sur l'écran d'accueil est statique ; à connecter à une
  vraie API météo (ex. OpenWeatherMap) si souhaité.
