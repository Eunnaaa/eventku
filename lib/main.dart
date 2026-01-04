import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'EventKu',

            // 🌞 Light & 🌙 Dark Theme
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.isDark
                ? ThemeMode.dark
                : ThemeMode.light,

            // 🚪 ENTRY POINT APLIKASI
            home: const AuthGate(),

            // (opsional) Global fallback error UI
            builder: (context, widget) {
              ErrorWidget.builder = (FlutterErrorDetails details) {
                debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Terjadi kesalahan',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              };
              return widget!;
            },
          );
        },
      ),
    );
  }
}
