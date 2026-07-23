import 'user_model.dart';
import 'parcelle_model.dart';

class StatsProfilModel {
  final int nbCultures;
  final int anneesExperience;
  final double superficieTotaleHa;

  StatsProfilModel({
    required this.nbCultures,
    required this.anneesExperience,
    required this.superficieTotaleHa,
  });

  factory StatsProfilModel.fromJson(Map<String, dynamic> json) => StatsProfilModel(
        nbCultures: json['nb_cultures'],
        anneesExperience: json['annees_experience'],
        superficieTotaleHa: (json['superficie_totale_ha'] as num).toDouble(),
      );
}

class ResumePrevisionsModel {
  final int nbPrevisions;
  final int nbRecommandations;
  final int nbAlertes;

  ResumePrevisionsModel({
    required this.nbPrevisions,
    required this.nbRecommandations,
    required this.nbAlertes,
  });

  factory ResumePrevisionsModel.fromJson(Map<String, dynamic> json) => ResumePrevisionsModel(
        nbPrevisions: json['nb_previsions'],
        nbRecommandations: json['nb_recommandations'],
        nbAlertes: json['nb_alertes'],
      );
}

class ProfilModel {
  final UserModel utilisateur;
  final StatsProfilModel stats;
  final List<ParcelleModel> mesCultures;
  final ResumePrevisionsModel resumePrevisions;

  ProfilModel({
    required this.utilisateur,
    required this.stats,
    required this.mesCultures,
    required this.resumePrevisions,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) => ProfilModel(
        utilisateur: UserModel.fromJson(json['utilisateur']),
        stats: StatsProfilModel.fromJson(json['stats']),
        mesCultures: (json['mes_cultures'] as List)
            .map((e) => ParcelleModel.fromJson(e))
            .toList(),
        resumePrevisions: ResumePrevisionsModel.fromJson(json['resume_previsions']),
      );
}
