import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/screens/shell/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  runApp(const AgroSenseApp());
}

class AgroSenseApp extends StatelessWidget {
  const AgroSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: AuthRepository()),
      child: MaterialApp(
        title: 'AgroSense',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('fr', 'CM'),
        supportedLocales: const [Locale('fr', 'CM'), Locale('fr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AuthGate(),
      ),
    );
  }
}
