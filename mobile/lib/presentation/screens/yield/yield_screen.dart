import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/rendement_model.dart';
import '../../blocs/rendement/rendement_bloc.dart';
import '../../widgets/common_widgets.dart';

const _typesSol = ['Argilo-limoneux', 'Sableux', 'Limoneux', 'Argileux', 'Latéritique'];
const _saisons = ['Grande saison', 'Petite saison'];
const _pluviometries = ['Faible', 'Normale', 'Forte'];

class YieldScreen extends StatefulWidget {
  const YieldScreen({super.key});

  @override
  State<YieldScreen> createState() => _YieldScreenState();
}

class _YieldScreenState extends State<YieldScreen> {
  final _superficieController = TextEditingController(text: '1.5');
  String _typeSol = _typesSol.first;
  String _saison = _saisons.first;
  String _pluviometrie = _pluviometries[1];

  @override
  void dispose() {
    _superficieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<RendementBloc, RendementState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: ScreenHeader(
                  background: AppColors.primary,
                  title: 'Rendements',
                  subtitle: 'Estimez la production de votre parcelle',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Simuler un rendement', style: AppTextStyles.serif(fontSize: 15)),
                          const SizedBox(height: 16),
                          _label('Culture'),
                          if (state.cultures.isEmpty)
                            const LinearProgressIndicator(color: AppColors.primary)
                          else
                            DropdownButtonFormField(
                              value: state.cultureSelectionnee,
                              items: state.cultures
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c.nom)))
                                  .toList(),
                              onChanged: (c) {
                                if (c != null) context.read<RendementBloc>().add(RendementCultureChangee(c));
                              },
                            ),
                          const SizedBox(height: 14),
                          _label('Superficie (hectares)'),
                          TextFormField(
                            controller: _superficieController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(suffixText: 'ha'),
                          ),
                          const SizedBox(height: 14),
                          _label('Type de sol'),
                          DropdownButtonFormField(
                            value: _typeSol,
                            items: _typesSol.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _typeSol = v ?? _typeSol),
                          ),
                          const SizedBox(height: 14),
                          _label('Saison'),
                          DropdownButtonFormField(
                            value: _saison,
                            items: _saisons.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _saison = v ?? _saison),
                          ),
                          const SizedBox(height: 14),
                          _label('Pluviométrie attendue'),
                          DropdownButtonFormField(
                            value: _pluviometrie,
                            items: _pluviometries.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _pluviometrie = v ?? _pluviometrie),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: state.status == RendementStatus.calcul || state.cultureSelectionnee == null
                                ? null
                                : () {
                                    final superficie = double.tryParse(
                                        _superficieController.text.replaceAll(',', '.')) ?? 0;
                                    if (superficie <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Veuillez saisir une superficie valide.')),
                                      );
                                      return;
                                    }
                                    context.read<RendementBloc>().add(RendementCalculDemande(
                                          superficieHa: superficie,
                                          typeSol: _typeSol,
                                          saison: _saison,
                                          pluviometrie: _pluviometrie,
                                        ));
                                  },
                            child: state.status == RendementStatus.calcul
                                ? const SizedBox(
                                    height: 18, width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Calculer le rendement'),
                          ),
                        ],
                      ),
                    ),
                    if (state.resultat != null) ...[
                      const SizedBox(height: 20),
                      const SectionTitle('Résultat de la simulation'),
                      _CarteResultat(resultat: state.resultat!),
                    ],
                    if (state.historique.length >= 2) ...[
                      const SizedBox(height: 20),
                      const SectionTitle('Historique des simulations'),
                      _GraphiqueHistorique(historique: state.historique),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: AppTextStyles.sans(fontSize: 12, color: AppColors.textSecondary)),
      );
}

class _CarteResultat extends StatelessWidget {
  final RendementPredictionModel resultat;
  const _CarteResultat({required this.resultat});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Color(int.parse(resultat.culture.couleur.replaceFirst('#', '0xFF'))).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco_rounded,
                  color: Color(int.parse(resultat.culture.couleur.replaceFirst('#', '0xFF'))),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${resultat.culture.nom} — ${resultat.superficieHa} ha',
                    style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ligneResultat('Rendement estimé', '${resultat.rendementEstimeTHa} t/ha'),
          _ligneResultat('Production totale', '${resultat.productionTotaleKg.round()} kg'),
          _ligneResultat('Revenu estimé', AppFormatters.fcfa(resultat.revenuEstimeFcfa)),
        ],
      ),
    );
  }

  Widget _ligneResultat(String label, String valeur) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.sans(fontSize: 12, color: AppColors.textSecondary)),
            Text(valeur, style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ],
        ),
      );
}

class _GraphiqueHistorique extends StatelessWidget {
  final List<RendementPredictionModel> historique;
  const _GraphiqueHistorique({required this.historique});

  @override
  Widget build(BuildContext context) {
    final derniers = historique.length > 8 ? historique.sublist(historique.length - 8) : historique;
    return AppCard(
      child: SizedBox(
        height: 160,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: [
              for (var i = 0; i < derniers.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: derniers[i].rendementEstimeTHa as double,
                    color: AppColors.primary,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}
