import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/profil_model.dart';
import '../../../data/repositories/profil_repository.dart';

// ── Events ───────────────────────────────────────────────────────────────

abstract class ProfilEvent extends Equatable {
  const ProfilEvent();
  @override
  List<Object?> get props => [];
}

class ProfilChargementDemande extends ProfilEvent {
  const ProfilChargementDemande();
}

// ── State ────────────────────────────────────────────────────────────────

enum ProfilStatus { initial, chargement, succes, erreur }

class ProfilState extends Equatable {
  final ProfilStatus status;
  final ProfilModel? profil;
  final String? messageErreur;

  const ProfilState({this.status = ProfilStatus.initial, this.profil, this.messageErreur});

  ProfilState copyWith({ProfilStatus? status, ProfilModel? profil, String? messageErreur}) {
    return ProfilState(
      status: status ?? this.status,
      profil: profil ?? this.profil,
      messageErreur: messageErreur,
    );
  }

  @override
  List<Object?> get props => [status, profil, messageErreur];
}

// ── Bloc ─────────────────────────────────────────────────────────────────

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  ProfilBloc({required ProfilRepository profilRepository})
      : _profilRepository = profilRepository,
        super(const ProfilState()) {
    on<ProfilChargementDemande>(_onChargementDemande);
  }

  final ProfilRepository _profilRepository;

  Future<void> _onChargementDemande(ProfilChargementDemande event, Emitter<ProfilState> emit) async {
    emit(state.copyWith(status: ProfilStatus.chargement));
    try {
      final profil = await _profilRepository.obtenirProfil();
      emit(state.copyWith(status: ProfilStatus.succes, profil: profil));
    } catch (e) {
      emit(state.copyWith(status: ProfilStatus.erreur, messageErreur: e.toString()));
    }
  }
}
