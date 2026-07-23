import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

enum AuthStatus { inconnu, verification, authentifie, nonAuthentifie }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? utilisateur;
  final String? messageErreur;

  const AuthState({
    this.status = AuthStatus.inconnu,
    this.utilisateur,
    this.messageErreur,
  });

  const AuthState.inconnu() : this(status: AuthStatus.inconnu);
  const AuthState.verification() : this(status: AuthStatus.verification);
  const AuthState.authentifie(UserModel user) : this(status: AuthStatus.authentifie, utilisateur: user);
  const AuthState.nonAuthentifie([String? message])
      : this(status: AuthStatus.nonAuthentifie, messageErreur: message);

  @override
  List<Object?> get props => [status, utilisateur, messageErreur];
}
