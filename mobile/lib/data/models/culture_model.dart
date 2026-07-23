class CultureModel {
  final int id;
  final String nom;
  final String categorieAgronomique;
  final String couleur;
  final int? cycleJours;

  CultureModel({
    required this.id,
    required this.nom,
    required this.categorieAgronomique,
    required this.couleur,
    this.cycleJours,
  });

  factory CultureModel.fromJson(Map<String, dynamic> json) => CultureModel(
        id: json['id'],
        nom: json['nom'],
        categorieAgronomique: json['categorie_agronomique'] ?? '',
        couleur: json['couleur'] ?? '#2E6B28',
        cycleJours: json['cycle_jours'],
      );
}
