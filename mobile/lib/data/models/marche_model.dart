class MarcheModel {
  final int id;
  final String nom;
  final String ville;
  final String region;
  final double? prixFcfaKg;

  MarcheModel({
    required this.id,
    required this.nom,
    required this.ville,
    required this.region,
    this.prixFcfaKg,
  });

  factory MarcheModel.fromJson(Map<String, dynamic> json) => MarcheModel(
        id: json['id'],
        nom: json['nom'],
        ville: json['ville'],
        region: json['region'],
        prixFcfaKg: (json['prix_fcfa_kg'] as num?)?.toDouble(),
      );
}
