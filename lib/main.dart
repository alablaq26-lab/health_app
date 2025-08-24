import 'package:flutter/material.dart';
import 'app_shell.dart';
import 'pages/emergency_info_page.dart';

void main() => runApp(const HealthApp());

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

      // الشاشة الرئيسية للتطبيق
      home: const AppShell(),

      // مسارات مسماة جاهزة للـ pushNamed وللاستخدام مع QR
      routes: {
        '/emergency': (_) => const EmergencyInfoPage(),
      },

      // دعم روابط مخصصة مثل healthapp://emergency (لو فعّلت URL scheme)
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name == 'healthapp://emergency') {
          return MaterialPageRoute(builder: (_) => const EmergencyInfoPage());
        }
        return null; // استخدم السلوك الافتراضي لباقي المسارات
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
