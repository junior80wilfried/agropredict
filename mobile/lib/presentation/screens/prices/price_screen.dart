import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/hex_color.dart';
import '../../../data/models/prix_resume_model.dart';
import '../../blocs/prix/prix_bloc.dart';
import '../../widgets/common_widgets.dart';

class PriceScreen extends StatelessWidget {
  const PriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<PrixBloc, PrixState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ScreenHeader(
                  background: AppColors.secondary,
                  title: 'Prix du marché',
                  subtitle: 'Suivi et prédiction des prix par culture',
                ),
              ),
              if (state.cultures.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.cultures.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final culture = state.cultures[i];
                        final selectionnee = culture.id == state.cultureSelectionneeId;
                        return ChoiceChip(
                          label: Text(culture.nom),
                          selected: selectionnee,
                          selectedColor: AppColors.secondary,
                          backgroundColor: AppColors.chipUnselectedBg,
                          side: BorderSide(color: AppColors.border),
                          labelStyle: AppTextStyles.sans(
                            fontSize: 12,
                            color: selectionnee ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) =>
                              context.read<PrixBloc>().add(PrixCultureSelectionnee(culture.id)),
                        );
                      },
                    ),
                  ),
                ),
              if (state.status == PrixStatus.chargement && state.resume == null)
                const SliverFillRemaining(child: LoadingView())
              else if (state.status == PrixStatus.erreur && state.resume == null)
                SliverFillRemaining(
                  child: ErrorView(
                    message: state.messageErreur ?? 'Impossible de charger les prix.',
                    onRetry: () => context.read<PrixBloc>().add(const PrixChargementDemande()),
                  ),
                )
              else if (state.resume != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _CartePrixActuel(resume: state.resume!),
                      const SizedBox(height: 16),
                      if (state.resume!.historique.length >= 2) ...[
                        const SectionTitle('Évolution (6 derniers mois)'),
                        _GraphiquePrix(resume: state.resume!),
                        const SizedBox(height: 20),
                      ],
                      if (state.resume!.prediction != null) ...[
                        const SectionTitle('Prédiction (7 prochains jours)'),
                        _CartePrediction(resume: state.resume!),
                        const SizedBox(height: 20),
                      ],
                      const SectionTitle('Marchés à proximité'),
                      if (state.marches.isEmpty)
                        Text('Aucun marché trouvé.', style: AppTextStyles.sans(color: AppColors.textSecondary))
                      else
                        ...state.marches.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.statAmberBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(m.nom, style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w800)),
                                          Text('${m.ville}, ${m.region}',
                                              style: AppTextStyles.sans(fontSize: 11, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      m.prixFcfaKg != null ? AppFormatters.prixKg(m.prixFcfaKg!) : '—',
                                      style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.secondary),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CartePrixActuel extends StatelessWidget {
  final PrixResumeModel resume;
  const _CartePrixActuel({required this.resume});

  @override
  Widget build(BuildContext context) {
    final enHausse = resume.enHausse == true;
    final couleur = hexToColor(resume.culture.couleur, fallback: AppColors.secondary);

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco_rounded, color: couleur, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resume.culture.nom, style: AppTextStyles.sans(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  resume.prixActuel != null ? AppFormatters.prixKg(resume.prixActuel!) : '—',
                  style: AppTextStyles.serif(fontSize: 20),
                ),
              ],
            ),
          ),
          if (resume.variationPct != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: enHausse ? AppColors.statGreenBg : const Color(0xFFF6D9D9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(enHausse ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 14, color: enHausse ? AppColors.success : AppColors.danger),
                  const SizedBox(width: 3),
                  Text('${resume.variationPct}%',
                      style: AppTextStyles.sans(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: enHausse ? AppColors.success : AppColors.danger,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GraphiquePrix extends StatelessWidget {
  final PrixResumeModel resume;
  const _GraphiquePrix({required this.resume});

  @override
  Widget build(BuildContext context) {
    final points = resume.historique;
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].prixFcfaKg),
    ];
    final couleur = hexToColor(resume.culture.couleur, fallback: AppColors.secondary);

    return AppCard(
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: couleur,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: couleur.withValues(alpha: 0.12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartePrediction extends StatelessWidget {
  final PrixResumeModel resume;
  const _CartePrediction({required this.resume});

  @override
  Widget build(BuildContext context) {
    final p = resume.prediction;
    if (p == null) return const SizedBox.shrink();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text('Prix projeté', style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(AppFormatters.prixKg(p.prixFusion),
                  style: AppTextStyles.serif(fontSize: 16, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Fusion Prophet (${(p.poidsProphet * 100).round()}%) + Random Forest (${(p.poidsRandomForest * 100).round()}%)',
            style: AppTextStyles.sans(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
