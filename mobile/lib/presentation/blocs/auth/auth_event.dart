import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthConnexionRequested extends AuthEvent {
  final String email;
  final String motDePasse;
  const AuthConnexionRequested({required this.email, required this.motDePasse});
  @override
  List<Object?> get props => [email, motDePasse];
}

class AuthInscriptionRequested extends AuthEvent {
  final String nom;
  final String email;
  final String motDePasse;
  final String? ville;
  final String? region;
  final int? agriculteurDepuis;

  const AuthInscriptionRequested({
    required this.nom,
    required this.email,
    required this.motDePasse,
    this.ville,
    this.region,
    this.agriculteurDepuis,
  });

  @override
  List<Object?> get props => [nom, email, motDePasse, ville, region, agriculteurDepuis];
}

class AuthDeconnexionRequested extends AuthEvent {
  const AuthDeconnexionRequested();
}
