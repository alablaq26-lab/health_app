import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_theme.dart';
import 'app_shell.dart';
import 'pages/login_page.dart';
import 'pages/emergency_info_page.dart';

/// مفاتيح Supabase (من Project Settings > API)
const String kSupabaseUrl = 'https://zeebbduwxilnvjdzdzfs.supabase.co';
const String kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InplZWJiZHV3eGlsbnZqZHpkemZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU2MzExNTAsImV4cCI6MjA3MTIwNzE1MH0.-4qj3EjO45soQNM1o31Ixsdq9aXxTBc0NMPRL6wdZZI';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      theme: AppTheme.light(),
      darkTheme: ThemeData.dark(useMaterial3: true),

      // نبدأ بصفحة تسجيل الدخول
      home: const LoginPage(),

      // كل التنقّلات الديناميكية (ومرور nationalId) هنا
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';

        // deep link: healthapp://emergency?nid=...
        if (name.startsWith('healthapp://emergency')) {
          final uri = Uri.parse(name);
          final nid = uri.queryParameters['nid'];
          return MaterialPageRoute(
            builder: (_) => (nid != null && nid.isNotEmpty)
                ? EmergencyInfoPage(nationalId: nid)
                : const Scaffold(
                    body:
                        Center(child: Text('Missing national_id in deep link')),
                  ),
          );
        }

        // route داخلي: /emergency مع arguments: {'nid': '...'}
        if (name == '/emergency') {
          final args = (settings.arguments ?? {}) as Map?;
          final nid = args?['nid']?.toString();
          return MaterialPageRoute(
            builder: (_) => (nid != null && nid.isNotEmpty)
                ? EmergencyInfoPage(nationalId: nid)
                : const Scaffold(
                    body: Center(
                        child: Text('Missing national_id in /emergency')),
                  ),
          );
        }

        // ✅ الصفحة الرئيسية: نستقبل nationalId
        if (name == '/home') {
          final args = (settings.arguments ?? {}) as Map?;
          final nid = args?['nid']?.toString();
          return MaterialPageRoute(
            builder: (_) => (nid != null && nid.isNotEmpty)
                ? AppShell(nationalId: nid)
                : const Scaffold(
                    body: Center(child: Text('Missing national_id for /home')),
                  ),
          );
        }

        return null;
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
