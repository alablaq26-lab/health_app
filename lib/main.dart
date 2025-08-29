import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_shell.dart';
import 'pages/login_page.dart';
import 'pages/emergency_info_page.dart';

/// ضع مفاتيح Supabase هنا 👇 (من Project Settings > API)
const String kSupabaseUrl = 'https://zeebbduwxilnvjdzdzfs.supabase.co';
const String kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InplZWJiZHV3eGlsbnZqZHpkemZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU2MzExNTAsImV4cCI6MjA3MTIwNzE1MH0.-4qj3EjO45soQNM1o31Ixsdq9aXxTBc0NMPRL6wdZZI';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

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

      /// ابدأ بصفحة الدخول (بدّلها لاحقًا لو حبيت)
      home: const LoginPage(),

      routes: {
        '/home': (_) => const AppShell(),
      },

      /// دعم deep-link:
      /// - healthapp://emergency?nid=66142020
      /// - أو دفع route يدويًا: /emergency مع arguments: {'nid': '...'}
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';

        // 1) لو جاي عبر deep-link healthapp://emergency?nid=...
        if (name.startsWith('healthapp://emergency')) {
          final uri = Uri.parse(name);
          final nid = uri.queryParameters['nid'];
          if (nid != null && nid.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => EmergencyInfoPage(nationalId: nid),
            );
          }
          // بدون nid نعرض رسالة بسيطة
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Missing national_id in deep link')),
            ),
          );
        }

        // 2) مسار داخلي اختياري: /emergency مع تمرير arguments: {'nid': '...'}
        if (name == '/emergency') {
          final args = (settings.arguments ?? {}) as Map?;
          final nid = args?['nid']?.toString();
          if (nid != null && nid.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => EmergencyInfoPage(nationalId: nid),
            );
          }
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Missing national_id in /emergency')),
            ),
          );
        }

        return null; // استخدم routes العادية
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
