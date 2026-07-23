class PrixPointModel {
  final DateTime date;
  final double prixFcfaKg;

  PrixPointModel({required this.date, required this.prixFcfaKg});

  factory PrixPointModel.fromJson(Map<String, dynamic> json) => PrixPointModel(
        date: DateTime.parse(json['date']),
        prixFcfaKg: (json['prix_fcfa_kg'] as num).toDouble(),
      );
}
