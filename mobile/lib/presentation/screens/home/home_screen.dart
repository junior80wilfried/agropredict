import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/alerte_model.dart';
import '../../blocs/home/home_bloc.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/tab_switcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.chargement || state.status == HomeStatus.initial) {
            return const LoadingView();
          }
          if (state.status == HomeStatus.erreur) {
            return ErrorView(
              message: state.messageErreur ?? 'Impossible de charger vos données.',
              onRetry: () => context.read<HomeBloc>().add(const HomeChargementDemande()),
            );
          }

          final user = state.utilisateur;
          final prenom = (user?.nom.split(' ').first) ?? 'Agriculteur';

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => context.read<HomeBloc>().add(const HomeChargementDemande()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.primary,
                    padding: EdgeInsets.only(
                      left: 20, right: 20, bottom: 22,
                      top: MediaQuery.of(context).padding.top + 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bonjour, $prenom',
                                  style: AppTextStyles.serif(fontSize: 21, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(
                                user?.ville != null ? '${user!.ville}, Cameroun' : 'Cameroun',
                                style: AppTextStyles.sans(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        _CarteMeteo(),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Expanded(
                            child: _CarteStat(
                              icone: Icons.trending_up_rounded,
                              couleurFond: AppColors.statAmberBg,
                              titre: state.cultureVedette?.culture.nom ?? 'Culture',
                              valeur: state.prixCultureVedette?.prixActuel != null
                                  ? AppFormatters.prixKg(state.prixCultureVedette!.prixActuel!)
                                  : '—',
                              sousTitre: state.prixCultureVedette?.variationPct != null
                                  ? '${state.prixCultureVedette!.variationPct! >= 0 ? '+' : ''}${state.prixCultureVedette!.variationPct}% cette semaine'
                                  : 'Prix actuel',
                              positif: state.prixCultureVedette?.enHausse ?? true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CarteStat(
                              icone: Icons.bar_chart_rounded,
                              couleurFond: AppColors.statGreenBg,
                              titre: 'Rendement prévu',
                              valeur: state.cultureVedette?.rendementEstime ?? '—',
                              sousTitre: state.cultureVedette != null
                                  ? 'Score ${state.cultureVedette!.score}/100'
                                  : 'Culture recommandée',
                              positif: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle('Accès rapide'),
                      _GrilleActionsRapides(),
                      const SizedBox(height: 24),
                      const SectionTitle('Alertes du marché'),
                      if (state.alertes.isEmpty)
                        Text('Aucune alerte pour le moment.',
                            style: AppTextStyles.sans(color: AppColors.textSecondary))
                      else
                        ...state.alertes.map((a) => _CarteAlerte(alerte: a)),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CarteMeteo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text('27°C', style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}

class _CarteStat extends StatelessWidget {
  final IconData icone;
  final Color couleurFond;
  final String titre;
  final String valeur;
  final String sousTitre;
  final bool positif;

  const _CarteStat({
    required this.icone,
    required this.couleurFond,
    required this.titre,
    required this.valeur,
    required this.sousTitre,
    required this.positif,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: couleurFond, borderRadius: BorderRadius.circular(10)),
            child: Icon(icone, size: 17, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(titre, style: AppTextStyles.sans(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(valeur, style: AppTextStyles.serif(fontSize: 16)),
          const SizedBox(height: 3),
          Text(
            sousTitre,
            style: AppTextStyles.sans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: positif ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrilleActionsRapides extends StatelessWidget {
  static const _actions = [
    (Icons.trending_up_rounded, 'Prix', AppColors.secondary, 1),
    (Icons.bar_chart_rounded, 'Rendements', AppColors.primary, 2),
    (Icons.eco_rounded, 'Cultures', AppColors.tertiary, 3),
    (Icons.person_rounded, 'Profil', AppColors.profile, 4),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: _actions.map((a) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => TabSwitcher.of(context).switchTab(a.$4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: a.$3.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(a.$1, color: a.$3, size: 22),
              ),
              const SizedBox(height: 6),
              Text(a.$2, style: AppTextStyles.sans(fontSize: 10)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CarteAlerte extends StatelessWidget {
  final AlerteModel alerte;
  const _CarteAlerte({required this.alerte});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.statAmberBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active_rounded, size: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alerte.titre, style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(alerte.message,
                      style: AppTextStyles.sans(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
