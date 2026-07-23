import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.inconnu()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthConnexionRequested>(_onConnexionRequested);
    on<AuthInscriptionRequested>(_onInscriptionRequested);
    on<AuthDeconnexionRequested>(_onDeconnexionRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.verification());
    final utilisateur = await _authRepository.utilisateurConnecte();
    if (utilisateur != null) {
      emit(AuthState.authentifie(utilisateur));
    } else {
      emit(const AuthState.nonAuthentifie());
    }
  }

  Future<void> _onConnexionRequested(AuthConnexionRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.verification());
    try {
      final utilisateur = await _authRepository.connexion(
        email: event.email,
        motDePasse: event.motDePasse,
      );
      emit(AuthState.authentifie(utilisateur));
    } on ApiException catch (e) {
      emit(AuthState.nonAuthentifie(e.message));
    }
  }

  Future<void> _onInscriptionRequested(AuthInscriptionRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.verification());
    try {
      final utilisateur = await _authRepository.inscription(
        nom: event.nom,
        email: event.email,
        motDePasse: event.motDePasse,
        ville: event.ville,
        region: event.region,
        agriculteurDepuis: event.agriculteurDepuis,
      );
      emit(AuthState.authentifie(utilisateur));
    } on ApiException catch (e) {
      emit(AuthState.nonAuthentifie(e.message));
    }
  }

  Future<void> _onDeconnexionRequested(AuthDeconnexionRequested event, Emitter<AuthState> emit) async {
    await _authRepository.deconnexion();
    emit(const AuthState.nonAuthentifie());
  }
}
