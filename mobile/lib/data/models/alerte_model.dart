class AlerteModel {
  final int id;
  final String titre;
  final String message;
  final String type;
  final String couleur;

  AlerteModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.couleur,
  });

  factory AlerteModel.fromJson(Map<String, dynamic> json) => AlerteModel(
        id: json['id'],
        titre: json['titre'],
        message: json['message'],
        type: json['type'] ?? 'info',
        couleur: json['couleur'] ?? '#C8892A',
      );
}
