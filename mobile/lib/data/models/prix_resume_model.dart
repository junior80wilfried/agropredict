import 'culture_model.dart';
import 'prix_point_model.dart';

class PredictionPrixModel {
  final double prixProphet;
  final double prixRandomForest;
  final double prixFusion;
  final double poidsProphet;
  final double poidsRandomForest;

  PredictionPrixModel({
    required this.prixProphet,
    required this.prixRandomForest,
    required this.prixFusion,
    required this.poidsProphet,
    required this.poidsRandomForest,
  });

  factory PredictionPrixModel.fromJson(Map<String, dynamic> json) => PredictionPrixModel(
        prixProphet: (json['prix_prophet'] as num).toDouble(),
        prixRandomForest: (json['prix_random_forest'] as num).toDouble(),
        prixFusion: (json['prix_fusion'] as num).toDouble(),
        poidsProphet: (json['poids_prophet'] as num).toDouble(),
        poidsRandomForest: (json['poids_random_forest'] as num).toDouble(),
      );
}

class PrixResumeModel {
  final CultureModel culture;
  final List<PrixPointModel> historique;
  final double? prixActuel;
  final double? variationPct;
  final bool enHausse;
  final PredictionPrixModel? prediction;

  PrixResumeModel({
    required this.culture,
    required this.historique,
    this.prixActuel,
    this.variationPct,
    this.enHausse = true,
    this.prediction,
  });

  factory PrixResumeModel.fromJson(Map<String, dynamic> json) => PrixResumeModel(
        culture: CultureModel.fromJson(json['culture']),
        historique: (json['historique'] as List)
            .map((e) => PrixPointModel.fromJson(e))
            .toList(),
        prixActuel: (json['prix_actuel'] as num?)?.toDouble(),
        variationPct: (json['variation_pct'] as num?)?.toDouble(),
        enHausse: json['en_hausse'] ?? true,
        prediction: json['prediction'] != null
            ? PredictionPrixModel.fromJson(json['prediction'])
            : null,
      );
}
