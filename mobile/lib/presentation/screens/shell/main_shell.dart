import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/alertes_repository.dart';
import '../../../data/repositories/cultures_repository.dart';
import '../../../data/repositories/prix_repository.dart';
import '../../../data/repositories/profil_repository.dart';
import '../../../data/repositories/rendement_repository.dart';
import '../../blocs/cultures/cultures_bloc.dart';
import '../../blocs/home/home_bloc.dart';
import '../../blocs/prix/prix_bloc.dart';
import '../../blocs/profil/profil_bloc.dart';
import '../../blocs/rendement/rendement_bloc.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/tab_switcher.dart';
import '../crops/crop_screen.dart';
import '../home/home_screen.dart';
import '../prices/price_screen.dart';
import '../profile/profile_screen.dart';
import '../yield/yield_screen.dart';

/// Coquille principale de l'app : gère la navigation par onglets et fournit
/// un bloc dédié à chacun des 5 écrans (créé une seule fois, conservé grâce
/// à l'IndexedStack pour ne pas perdre l'état en changeant d'onglet).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeBloc(
            profilRepository: ProfilRepository(),
            culturesRepository: CulturesRepository(),
            prixRepository: PrixRepository(),
            alertesRepository: AlertesRepository(),
          )..add(const HomeChargementDemande()),
        ),
        BlocProvider(
          create: (_) => PrixBloc(
            culturesRepository: CulturesRepository(),
            prixRepository: PrixRepository(),
          )..add(const PrixChargementDemande()),
        ),
        BlocProvider(
          create: (_) => RendementBloc(
            culturesRepository: CulturesRepository(),
            rendementRepository: RendementRepository(),
          )..add(const RendementCulturesChargementDemande()),
        ),
        BlocProvider(
          create: (_) => CulturesBloc(
            culturesRepository: CulturesRepository(),
          )..add(const CulturesRecommandationsDemandees()),
        ),
        BlocProvider(
          create: (_) => ProfilBloc(
            profilRepository: ProfilRepository(),
          )..add(const ProfilChargementDemande()),
        ),
      ],
      child: TabSwitcher(
        switchTab: (i) => setState(() => _index = i),
        child: Scaffold(
          body: IndexedStack(
            index: _index,
            children: const [
              HomeScreen(),
              PriceScreen(),
              YieldScreen(),
              CropScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: BottomNav(
            active: _index,
            onChange: (i) => setState(() => _index = i),
          ),
        ),
      ),
    );
  }
}
