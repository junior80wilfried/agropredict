import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../auth/login_screen.dart';
import 'main_shell.dart';
import 'splash_screen.dart';

/// Bascule automatiquement entre l'écran de connexion et l'app principale
/// selon l'état de la session (token JWT présent et valide ou non).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.inconnu:
          case AuthStatus.verification:
            return const SplashScreen();
          case AuthStatus.authentifie:
            return const MainShell();
          case AuthStatus.nonAuthentifie:
            return const LoginScreen();
        }
      },
    );
  }
}
