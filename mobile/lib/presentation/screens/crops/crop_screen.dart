import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/recommandation_model.dart';
import '../../blocs/cultures/cultures_bloc.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/tab_switcher.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CulturesBloc, CulturesState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: ScreenHeader(
                  background: AppColors.tertiary,
                  title: 'Cultures recommandées',
                  subtitle: 'Selon votre sol et la saison en cours',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _selecteur(
                          context,
                          valeur: state.typeSol,
                          options: const ['Argilo-limoneux', 'Sableux', 'Limoneux', 'Argileux', 'Latéritique'],
                          onChanged: (v) => context.read<CulturesBloc>().add(
                                CulturesRecommandationsDemandees(typeSol: v, saison: state.saison),
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _selecteur(
                          context,
                          valeur: state.saison,
                          options: const ['Grande saison', 'Petite saison'],
                          onChanged: (v) => context.read<CulturesBloc>().add(
                                CulturesRecommandationsDemandees(typeSol: state.typeSol, saison: v),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.status == CulturesStatus.chargement)
                const SliverFillRemaining(child: LoadingView())
              else if (state.status == CulturesStatus.erreur)
                SliverFillRemaining(
                  child: ErrorView(
                    message: state.messageErreur ?? 'Impossible de charger les recommandations.',
                    onRetry: () => context.read<CulturesBloc>().add(const CulturesRecommandationsDemandees()),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      for (final r in state.recommandations) _CarteRecommandation(reco: r),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _selecteur(
    BuildContext context, {
    required String valeur,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valeur,
          isExpanded: true,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: AppTextStyles.sans(fontSize: 12)))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _CarteRecommandation extends StatelessWidget {
  final RecommandationModel reco;
  const _CarteRecommandation({required this.reco});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Color(int.parse(reco.culture.couleur.replaceFirst('#', '0xFF'))).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: Color(int.parse(reco.culture.couleur.replaceFirst('#', '0xFF'))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reco.culture.nom, style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w800)),
                      Text(reco.culture.categorieAgronomique,
                          style: AppTextStyles.sans(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.statGreenBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${reco.score}/100',
                      style: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _mini('Rendement', reco.rendementEstime)),
                Expanded(
                  child: _mini(
                    'Prix marché',
                    reco.prixMarcheFcfaKg != null ? AppFormatters.prixKg(reco.prixMarcheFcfaKg!) : '—',
                  ),
                ),
                Expanded(child: _mini('Rentabilité', reco.rentabilite)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                for (final tag in reco.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statTealBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tag, style: AppTextStyles.sans(fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => TabSwitcher.of(context).switchTab(2), // 2 = onglet Rendements
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.tertiary,
                side: const BorderSide(color: AppColors.tertiary),
                minimumSize: const Size.fromHeight(38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simuler le rendement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(String label, String valeur) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.sans(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(valeur, style: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      );
}
