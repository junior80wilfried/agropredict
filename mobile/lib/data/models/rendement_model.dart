import 'culture_model.dart';

class RendementPredictionModel {
  final int id;
  final CultureModel culture;
  final double superficieHa;
  final String typeSol;
  final String saison;
  final String pluviometrie;
  final double rendementEstimeKgHa;
  final double rendementEstimeTHa;
  final double productionTotaleKg;
  final double revenuEstimeFcfa;
  final DateTime createdAt;

  RendementPredictionModel({
    required this.id,
    required this.culture,
    required this.superficieHa,
    required this.typeSol,
    required this.saison,
    required this.pluviometrie,
    required this.rendementEstimeKgHa,
    required this.rendementEstimeTHa,
    required this.productionTotaleKg,
    required this.revenuEstimeFcfa,
    required this.createdAt,
  });

  factory RendementPredictionModel.fromJson(Map<String, dynamic> json) => RendementPredictionModel(
        id: json['id'],
        culture: CultureModel.fromJson(json['culture']),
        superficieHa: (json['superficie_ha'] as num).toDouble(),
        typeSol: json['type_sol'],
        saison: json['saison'],
        pluviometrie: json['pluviometrie'],
        rendementEstimeKgHa: (json['rendement_estime_kg_ha'] as num).toDouble(),
        rendementEstimeTHa: (json['rendement_estime_t_ha'] as num).toDouble(),
        productionTotaleKg: (json['production_totale_kg'] as num).toDouble(),
        revenuEstimeFcfa: (json['revenu_estime_fcfa'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at']),
      );
}
