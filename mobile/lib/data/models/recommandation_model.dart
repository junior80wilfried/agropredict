import 'culture_model.dart';

class RecommandationModel {
  final CultureModel culture;
  final int score;
  final String rendementEstime;
  final double? prixMarcheFcfaKg;
  final String rentabilite;
  final List<String> tags;

  RecommandationModel({
    required this.culture,
    required this.score,
    required this.rendementEstime,
    this.prixMarcheFcfaKg,
    required this.rentabilite,
    required this.tags,
  });

  factory RecommandationModel.fromJson(Map<String, dynamic> json) => RecommandationModel(
        culture: CultureModel.fromJson(json['culture']),
        score: json['score'],
        rendementEstime: json['rendement_estime'],
        prixMarcheFcfaKg: (json['prix_marche_fcfa_kg'] as num?)?.toDouble(),
        rentabilite: json['rentabilite'],
        tags: List<String>.from(json['tags'] ?? []),
      );
}
