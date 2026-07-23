import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/alerte_model.dart';
import '../../../data/models/prix_resume_model.dart';
import '../../../data/models/recommandation_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/alertes_repository.dart';
import '../../../data/repositories/cultures_repository.dart';
import '../../../data/repositories/prix_repository.dart';
import '../../../data/repositories/profil_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeChargementDemande extends HomeEvent {
  const HomeChargementDemande();
}

// ── State ────────────────────────────────────────────────────────────────

enum HomeStatus { initial, chargement, succes, erreur }

class HomeState extends Equatable {
  final HomeStatus status;
  final UserModel? utilisateur;
  final PrixResumeModel? prixCultureVedette;
  final RecommandationModel? cultureVedette;
  final List<AlerteModel> alertes;
  final String? messageErreur;

  const HomeState({
    this.status = HomeStatus.initial,
    this.utilisateur,
    this.prixCultureVedette,
    this.cultureVedette,
    this.alertes = const [],
    this.messageErreur,
  });

  HomeState copyWith({
    HomeStatus? status,
    UserModel? utilisateur,
    PrixResumeModel? prixCultureVedette,
    RecommandationModel? cultureVedette,
    List<AlerteModel>? alertes,
    String? messageErreur,
  }) {
    return HomeState(
      status: status ?? this.status,
      utilisateur: utilisateur ?? this.utilisateur,
      prixCultureVedette: prixCultureVedette ?? this.prixCultureVedette,
      cultureVedette: cultureVedette ?? this.cultureVedette,
      alertes: alertes ?? this.alertes,
      messageErreur: messageErreur,
    );
  }

  @override
  List<Object?> get props =>
      [status, utilisateur, prixCultureVedette, cultureVedette, alertes, messageErreur];
}

// ── Bloc ─────────────────────────────────────────────────────────────────

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required ProfilRepository profilRepository,
    required CulturesRepository culturesRepository,
    required PrixRepository prixRepository,
    required AlertesRepository alertesRepository,
  })  : _profilRepository = profilRepository,
        _culturesRepository = culturesRepository,
        _prixRepository = prixRepository,
        _alertesRepository = alertesRepository,
        super(const HomeState()) {
    on<HomeChargementDemande>(_onChargementDemande);
  }

  final ProfilRepository _profilRepository;
  final CulturesRepository _culturesRepository;
  final PrixRepository _prixRepository;
  final AlertesRepository _alertesRepository;

  Future<void> _onChargementDemande(HomeChargementDemande event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.chargement));
    try {
      final profil = await _profilRepository.obtenirProfil();
      final recommandations = await _culturesRepository.recommandations(
        typeSol: 'Argilo-limoneux',
        saison: 'Grande saison',
      );
      final cultureVedette = recommandations.isNotEmpty ? recommandations.first : null;

      PrixResumeModel? prixVedette;
      if (cultureVedette != null) {
        prixVedette = await _prixRepository.resume(cultureVedette.culture.id);
      }

      final alertes = await _alertesRepository.lister();

      emit(state.copyWith(
        status: HomeStatus.succes,
        utilisateur: profil.utilisateur,
        prixCultureVedette: prixVedette,
        cultureVedette: cultureVedette,
        alertes: alertes,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.erreur, messageErreur: e.toString()));
    }
  }
}
