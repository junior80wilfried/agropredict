import 'culture_model.dart';

class ParcelleModel {
  final int id;
  final CultureModel culture;
  final double superficieHa;
  final String typeSol;
  final String statut;
  final String statutCouleur;

  ParcelleModel({
    required this.id,
    required this.culture,
    required this.superficieHa,
    required this.typeSol,
    required this.statut,
    required this.statutCouleur,
  });

  factory ParcelleModel.fromJson(Map<String, dynamic> json) => ParcelleModel(
        id: json['id'],
        culture: CultureModel.fromJson(json['culture']),
        superficieHa: (json['superficie_ha'] as num).toDouble(),
        typeSol: json['type_sol'],
        statut: json['statut'],
        statutCouleur: json['statut_couleur'] ?? '#7A6E5A',
      );
}
