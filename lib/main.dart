import 'package:flutter/material.dart';
import 'package:health_app/pages/somepage.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'app_shell.dart';
import 'pages/emergency_info_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final prefs = await SharedPreferences.getInstance();
  // final startLoggedIn = prefs.getBool('logged_in') ?? false;

  runApp(const HealthApp(
      // startLoggedIn: startLoggedIn,
      ));
}

class HealthApp extends StatelessWidget {
  // const HealthApp({super.key, required this.startLoggedIn});
  const HealthApp({super.key});
  // final bool startLoggedIn;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: const Color(0xFF1976D2),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );

    return MaterialApp(
      title: 'Health App',
      theme: theme,
      darkTheme: ThemeData.dark(useMaterial3: true),

      // هنا دايمًا يبدأ بـ LoginPage
      home: const LoginPage(),

      routes: {
        '/home': (_) => const AppShell(),
        '/emergency': (_) => const EmergencyInfoPage(),
        '/dashboard': (_) => const SomePage(),
      },

      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name == 'healthapp://emergency') {
          return MaterialPageRoute(builder: (_) => const EmergencyInfoPage());
        }
        return null;
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
