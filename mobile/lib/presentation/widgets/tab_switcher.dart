import 'package:flutter/material.dart';

/// Permet à n'importe quel écran enfant de changer d'onglet actif dans
/// [MainShell] (ex: bouton "Simuler le rendement" depuis l'écran Cultures)
/// sans empiler une nouvelle route par-dessus le Navigator racine — ce qui
/// perdrait l'accès aux blocs fournis au niveau de la coquille principale.
class TabSwitcher extends InheritedWidget {
  final void Function(int index) switchTab;

  const TabSwitcher({super.key, required this.switchTab, required super.child});

  static TabSwitcher of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<TabSwitcher>();
    assert(result != null, 'Aucun TabSwitcher trouvé dans le contexte.');
    return result!;
  }

  @override
  bool updateShouldNotify(TabSwitcher oldWidget) => false;
}
