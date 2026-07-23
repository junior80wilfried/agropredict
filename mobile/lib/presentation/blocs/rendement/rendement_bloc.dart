import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/culture_model.dart';
import '../../../data/models/rendement_model.dart';
import '../../../data/repositories/cultures_repository.dart';
import '../../../data/repositories/rendement_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────

abstract class RendementEvent extends Equatable {
  const RendementEvent();
  @override
  List<Object?> get props => [];
}

class RendementCulturesChargementDemande extends RendementEvent {
  const RendementCulturesChargementDemande();
}

class RendementCultureChangee extends RendementEvent {
  final CultureModel culture;
  const RendementCultureChangee(this.culture);
  @override
  List<Object?> get props => [culture];
}

class RendementCalculDemande extends RendementEvent {
  final double superficieHa;
  final String typeSol;
  final String saison;
  final String pluviometrie;

  const RendementCalculDemande({
    required this.superficieHa,
    required this.typeSol,
    required this.saison,
    required this.pluviometrie,
  });

  @override
  List<Object?> get props => [superficieHa, typeSol, saison, pluviometrie];
}

// ── State ────────────────────────────────────────────────────────────────

enum RendementStatus { initial, chargement, pret, calcul, resultat, erreur }

class RendementState extends Equatable {
  final RendementStatus status;
  final List<CultureModel> cultures;
  final CultureModel? cultureSelectionnee;
  final List<RendementPredictionModel> historique;
  final RendementPredictionModel? resultat;
  final String? messageErreur;

  const RendementState({
    this.status = RendementStatus.initial,
    this.cultures = const [],
    this.cultureSelectionnee,
    this.historique = const [],
    this.resultat,
    this.messageErreur,
  });

  RendementState copyWith({
    RendementStatus? status,
    List<CultureModel>? cultures,
    CultureModel? cultureSelectionnee,
    List<RendementPredictionModel>? historique,
    RendementPredictionModel? resultat,
    String? messageErreur,
  }) {
    return RendementState(
      status: status ?? this.status,
      cultures: cultures ?? this.cultures,
      cultureSelectionnee: cultureSelectionnee ?? this.cultureSelectionnee,
      historique: historique ?? this.historique,
      resultat: resultat ?? this.resultat,
      messageErreur: messageErreur,
    );
  }

  @override
  List<Object?> get props =>
      [status, cultures, cultureSelectionnee, historique, resultat, messageErreur];
}

// ── Bloc ─────────────────────────────────────────────────────────────────

class RendementBloc extends Bloc<RendementEvent, RendementState> {
  RendementBloc({
    required CulturesRepository culturesRepository,
    required RendementRepository rendementRepository,
  })  : _culturesRepository = culturesRepository,
        _rendementRepository = rendementRepository,
        super(const RendementState()) {
    on<RendementCulturesChargementDemande>(_onCulturesChargementDemande);
    on<RendementCultureChangee>(_onCultureChangee);
    on<RendementCalculDemande>(_onCalculDemande);
  }

  final CulturesRepository _culturesRepository;
  final RendementRepository _rendementRepository;

  Future<void> _onCulturesChargementDemande(
    RendementCulturesChargementDemande event,
    Emitter<RendementState> emit,
  ) async {
    emit(state.copyWith(status: RendementStatus.chargement));
    try {
      final cultures = await _culturesRepository.lister();
      emit(state.copyWith(
        status: RendementStatus.pret,
        cultures: cultures,
        cultureSelectionnee: cultures.isNotEmpty ? cultures.first : null,
      ));
    } catch (e) {
      emit(state.copyWith(status: RendementStatus.erreur, messageErreur: e.toString()));
    }
  }

  void _onCultureChangee(RendementCultureChangee event, Emitter<RendementState> emit) {
    emit(state.copyWith(cultureSelectionnee: event.culture));
  }

  Future<void> _onCalculDemande(RendementCalculDemande event, Emitter<RendementState> emit) async {
    final culture = state.cultureSelectionnee;
    if (culture == null) return;

    emit(state.copyWith(status: RendementStatus.calcul));
    try {
      final resultat = await _rendementRepository.predire(
        cultureId: culture.id,
        superficieHa: event.superficieHa,
        typeSol: event.typeSol,
        saison: event.saison,
        pluviometrie: event.pluviometrie,
      );
      final historique = await _rendementRepository.historique(cultureId: culture.id);
      emit(state.copyWith(
        status: RendementStatus.resultat,
        resultat: resultat,
        historique: historique,
      ));
    } catch (e) {
      emit(state.copyWith(status: RendementStatus.erreur, messageErreur: e.toString()));
    }
  }
}
