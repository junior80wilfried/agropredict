import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@agrosense.cm');
  final _motDePasseController = TextEditingController(text: 'demo1234');
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthConnexionRequested(
          email: _emailController.text.trim(),
          motDePasse: _motDePasseController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.nonAuthentifie && state.messageErreur != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.messageErreur!), backgroundColor: AppColors.danger),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    const Text('🌱', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 8),
                    Center(
                      child: Text('AgroSense', style: AppTextStyles.serif(fontSize: 30)),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Prix, rendements et recommandations\npour les cultures à cycle court',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sans(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text('Email', style: AppTextStyles.sans(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'vous@exemple.com'),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Email invalide' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Mot de passe', style: AppTextStyles.sans(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _motDePasseController,
                      obscureText: !_motDePasseVisible,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(_motDePasseVisible ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 6) ? '6 caractères minimum' : null,
                    ),
                    const SizedBox(height: 28),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final chargement = state.status == AuthStatus.verification;
                        return ElevatedButton(
                          onPressed: chargement ? null : _soumettre,
                          child: chargement
                              ? const SizedBox(
                                  height: 18, width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Se connecter'),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: "Pas encore de compte ? ",
                            style: AppTextStyles.sans(fontSize: 13, color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: "Créer un compte",
                                style: AppTextStyles.sans(
                                  fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
