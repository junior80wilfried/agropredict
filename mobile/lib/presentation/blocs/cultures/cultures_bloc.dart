import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/recommandation_model.dart';
import '../../../data/repositories/cultures_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────

abstract class CulturesEvent extends Equatable {
  const CulturesEvent();
  @override
  List<Object?> get props => [];
}

class CulturesRecommandationsDemandees extends CulturesEvent {
  final String typeSol;
  final String saison;
  const CulturesRecommandationsDemandees({
    this.typeSol = 'Argilo-limoneux',
    this.saison = 'Grande saison',
  });
  @override
  List<Object?> get props => [typeSol, saison];
}

// ── State ────────────────────────────────────────────────────────────────

enum CulturesStatus { initial, chargement, succes, erreur }

class CulturesState extends Equatable {
  final CulturesStatus status;
  final List<RecommandationModel> recommandations;
  final String typeSol;
  final String saison;
  final String? messageErreur;

  const CulturesState({
    this.status = CulturesStatus.initial,
    this.recommandations = const [],
    this.typeSol = 'Argilo-limoneux',
    this.saison = 'Grande saison',
    this.messageErreur,
  });

  CulturesState copyWith({
    CulturesStatus? status,
    List<RecommandationModel>? recommandations,
    String? typeSol,
    String? saison,
    String? messageErreur,
  }) {
    return CulturesState(
      status: status ?? this.status,
      recommandations: recommandations ?? this.recommandations,
      typeSol: typeSol ?? this.typeSol,
      saison: saison ?? this.saison,
      messageErreur: messageErreur,
    );
  }

  @override
  List<Object?> get props => [status, recommandations, typeSol, saison, messageErreur];
}

// ── Bloc ─────────────────────────────────────────────────────────────────

class CulturesBloc extends Bloc<CulturesEvent, CulturesState> {
  CulturesBloc({required CulturesRepository culturesRepository})
      : _culturesRepository = culturesRepository,
        super(const CulturesState()) {
    on<CulturesRecommandationsDemandees>(_onRecommandationsDemandees);
  }

  final CulturesRepository _culturesRepository;

  Future<void> _onRecommandationsDemandees(
    CulturesRecommandationsDemandees event,
    Emitter<CulturesState> emit,
  ) async {
    emit(state.copyWith(status: CulturesStatus.chargement, typeSol: event.typeSol, saison: event.saison));
    try {
      final recommandations = await _culturesRepository.recommandations(
        typeSol: event.typeSol,
        saison: event.saison,
      );
      emit(state.copyWith(status: CulturesStatus.succes, recommandations: recommandations));
    } catch (e) {
      emit(state.copyWith(status: CulturesStatus.erreur, messageErreur: e.toString()));
    }
  }
}
