import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bool initialIsDark = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    initialIsDark = prefs.getBool('isDark') ?? false;
  } catch (e) {
    debugPrint('Error loading theme preference: $e');
  }

  runApp(MyApp(initialIsDark: initialIsDark));
}

class MyApp extends StatelessWidget {
  final bool initialIsDark;

  const MyApp({super.key, this.initialIsDark = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(initialIsDark: initialIsDark),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'EventKu',

            // Light & Dark Theme
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.isDark
                ? ThemeMode.dark
                : ThemeMode.light,

            // ENTRY POINT APLIKASI
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
