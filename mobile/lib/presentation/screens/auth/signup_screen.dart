import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

const _regions = [
  'Centre', 'Littoral', 'Ouest', 'Nord-Ouest', 'Sud-Ouest',
  'Nord', 'Extrême-Nord', 'Adamaoua', 'Est', 'Sud',
];

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _villeController = TextEditingController(text: 'Yaoundé');
  final _motDePasseController = TextEditingController();
  String _region = 'Centre';
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _villeController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthInscriptionRequested(
          nom: _nomController.text.trim(),
          email: _emailController.text.trim(),
          motDePasse: _motDePasseController.text,
          ville: _villeController.text.trim(),
          region: _region,
          agriculteurDepuis: DateTime.now().year,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text('Créer un compte', style: AppTextStyles.serif(fontSize: 18)),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.nonAuthentifie && state.messageErreur != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.messageErreur!), backgroundColor: AppColors.danger),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label('Nom complet'),
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(hintText: 'Ex : Ngono Marie'),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 16),
                  _label('Email'),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'vous@exemple.com'),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 16),
                  _label('Ville'),
                  TextFormField(
                    controller: _villeController,
                    decoration: const InputDecoration(hintText: 'Ex : Yaoundé'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ville requise' : null,
                  ),
                  const SizedBox(height: 16),
                  _label('Région'),
                  DropdownButtonFormField<String>(
                    value: _region,
                    decoration: const InputDecoration(),
                    items: _regions
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _region = v ?? _region),
                  ),
                  const SizedBox(height: 16),
                  _label('Mot de passe'),
                  TextFormField(
                    controller: _motDePasseController,
                    obscureText: !_motDePasseVisible,
                    decoration: InputDecoration(
                      hintText: '6 caractères minimum',
                      suffixIcon: IconButton(
                        icon: Icon(_motDePasseVisible ? Icons.visibility_off : Icons.visibility, size: 20),
                        onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? '6 caractères minimum' : null,
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
                            : const Text('Créer mon compte'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: AppTextStyles.sans(fontSize: 12, color: AppColors.textSecondary)),
      );
}
