class UserModel {
  final int id;
  final String nom;
  final String email;
  final String? telephone;
  final String? ville;
  final String? region;
  final int? agriculteurDepuis;
  final int anneesExperience;
  final String initiales;

  UserModel({
    required this.id,
    required this.nom,
    required this.email,
    this.telephone,
    this.ville,
    this.region,
    this.agriculteurDepuis,
    this.anneesExperience = 0,
    this.initiales = '??',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        nom: json['nom'],
        email: json['email'],
        telephone: json['telephone'],
        ville: json['ville'],
        region: json['region'],
        agriculteurDepuis: json['agriculteur_depuis'],
        anneesExperience: json['annees_experience'] ?? 0,
        initiales: json['initiales'] ?? '??',
      );
}
