# AgroSense — App mobile Flutter

Application mobile pour agriculteurs camerounais : prix du marché,
prédiction de rendement, recommandations de cultures et suivi de profil.
Convertie depuis la maquette Figma Make "Mobile app mockup for agriculture"
vers une app Flutter connectée à un vrai backend Flask.

## Architecture

```
lib/
├── core/            # constantes, thème, réseau, stockage sécurisé, utilitaires
├── data/
│   ├── models/      # modèles de données (parsing JSON <-> objets Dart)
│   └── repositories/# appels API par domaine (auth, prix, rendement, cultures, profil, alertes)
└── presentation/
    ├── blocs/       # un BLoC par écran (flutter_bloc)
    ├── screens/     # les 5 écrans de la maquette + auth (login/signup) + coquille
    └── widgets/     # composants partagés (nav, cartes, en-têtes...)
```

État global géré avec **flutter_bloc**. Chaque écran principal (Accueil,
Prix, Rendements, Cultures, Profil) a son propre bloc, injecté une seule
fois dans `MainShell` et conservé grâce à un `IndexedStack` (pas de perte
d'état en changeant d'onglet).

## Installation

```bash
cd mobile
flutter pub get
```

### Configurer l'URL de l'API backend

Par défaut, l'app pointe vers `http://10.0.2.2:5000` (alias de `localhost`
pour l'émulateur Android). Adaptez selon votre environnement :

```bash
# Simulateur iOS / bureau
flutter run --dart-define=API_BASE_URL=http://localhost:5000

# Appareil physique (remplacez par l'IP de votre machine sur le réseau local)
flutter run --dart-define=API_BASE_URL=http://192.168.1.42:5000
```

### Lancer l'app

```bash
flutter run
```

Connectez-vous avec le compte de démonstration créé par `flask seed` côté
backend : `demo@agrosense.cm` / `demo1234`, ou créez un nouveau compte
depuis l'écran d'inscription.

## Écrans

| Écran | Description |
|---|---|
| **Connexion / Inscription** | Authentification JWT (absente de la maquette d'origine) |
| **Accueil** | Météo, prix du jour de la culture vedette, rendement prévu, accès rapide, alertes |
| **Prix** | Sélecteur de culture, historique 6 mois (graphique), prédiction fusionnée Prophet/RF, marchés proches |
| **Rendements** | Formulaire de simulation (culture, superficie, sol, saison, pluviométrie) + résultat + historique |
| **Cultures** | Recommandations triées par score, filtrables par sol/saison |
| **Profil** | Infos utilisateur, statistiques, "mes cultures", résumé, déconnexion |

## Notes

- Les couleurs des écrans reprennent la palette de la maquette Figma
  d'origine (vert `#2E6B28`, ambre `#C8892A`, etc.).
- Le stockage du token JWT utilise `flutter_secure_storage` (Keychain/Keystore).
- Le graphique de prix et l'historique de rendement utilisent `fl_chart`.
