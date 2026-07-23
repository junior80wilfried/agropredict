import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/culture_model.dart';
import '../../../data/models/marche_model.dart';
import '../../../data/models/prix_resume_model.dart';
import '../../../data/repositories/cultures_repository.dart';
import '../../../data/repositories/prix_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────

abstract class PrixEvent extends Equatable {
  const PrixEvent();
  @override
  List<Object?> get props => [];
}

class PrixChargementDemande extends PrixEvent {
  const PrixChargementDemande();
}

class PrixCultureSelectionnee extends PrixEvent {
  final int cultureId;
  const PrixCultureSelectionnee(this.cultureId);
  @override
  List<Object?> get props => [cultureId];
}

// ── State ────────────────────────────────────────────────────────────────

enum PrixStatus { initial, chargement, succes, erreur }

class PrixState extends Equatable {
  final PrixStatus status;
  final List<CultureModel> cultures;
  final int? cultureSelectionneeId;
  final PrixResumeModel? resume;
  final List<MarcheModel> marches;
  final String? messageErreur;

  const PrixState({
    this.status = PrixStatus.initial,
    this.cultures = const [],
    this.cultureSelectionneeId,
    this.resume,
    this.marches = const [],
    this.messageErreur,
  });

  PrixState copyWith({
    PrixStatus? status,
    List<CultureModel>? cultures,
    int? cultureSelectionneeId,
    PrixResumeModel? resume,
    List<MarcheModel>? marches,
    String? messageErreur,
  }) {
    return PrixState(
      status: status ?? this.status,
      cultures: cultures ?? this.cultures,
      cultureSelectionneeId: cultureSelectionneeId ?? this.cultureSelectionneeId,
      resume: resume ?? this.resume,
      marches: marches ?? this.marches,
      messageErreur: messageErreur,
    );
  }

  @override
  List<Object?> get props => [status, cultures, cultureSelectionneeId, resume, marches, messageErreur];
}

// ── Bloc ─────────────────────────────────────────────────────────────────

class PrixBloc extends Bloc<PrixEvent, PrixState> {
  PrixBloc({
    required CulturesRepository culturesRepository,
    required PrixRepository prixRepository,
  })  : _culturesRepository = culturesRepository,
        _prixRepository = prixRepository,
        super(const PrixState()) {
    on<PrixChargementDemande>(_onChargementDemande);
    on<PrixCultureSelectionnee>(_onCultureSelectionnee);
  }

  final CulturesRepository _culturesRepository;
  final PrixRepository _prixRepository;

  Future<void> _onChargementDemande(PrixChargementDemande event, Emitter<PrixState> emit) async {
    emit(state.copyWith(status: PrixStatus.chargement));
    try {
      final cultures = await _culturesRepository.lister();
      if (cultures.isEmpty) {
        emit(state.copyWith(status: PrixStatus.erreur, messageErreur: 'Aucune culture disponible.'));
        return;
      }
      final premiereCulture = cultures.first;
      final resume = await _prixRepository.resume(premiereCulture.id);
      final marches = await _prixRepository.marchesProches(premiereCulture.id);

      emit(state.copyWith(
        status: PrixStatus.succes,
        cultures: cultures,
        cultureSelectionneeId: premiereCulture.id,
        resume: resume,
        marches: marches,
      ));
    } catch (e) {
      emit(state.copyWith(status: PrixStatus.erreur, messageErreur: e.toString()));
    }
  }

  Future<void> _onCultureSelectionnee(PrixCultureSelectionnee event, Emitter<PrixState> emit) async {
    emit(state.copyWith(status: PrixStatus.chargement, cultureSelectionneeId: event.cultureId));
    try {
      final resume = await _prixRepository.resume(event.cultureId);
      final marches = await _prixRepository.marchesProches(event.cultureId);
      emit(state.copyWith(status: PrixStatus.succes, resume: resume, marches: marches));
    } catch (e) {
      emit(state.copyWith(status: PrixStatus.erreur, messageErreur: e.toString()));
    }
  }
}
