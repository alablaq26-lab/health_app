import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primary = Color(0xFF6F61FF); // بنفسجي هادئ
  static const Color _bg = Color(0xFFF6F7FB); // خلفية ناعمة
  static const Color _card = Colors.white;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      background: _bg,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _bg,
    );

    final textTheme = base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge
          ?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: base.textTheme.titleMedium
          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.35),
      bodyMedium:
          base.textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.35),
      labelLarge:
          base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(color: Colors.black87, fontSize: 24),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: _card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIconColor: Colors.black38,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        indicatorColor: _primary.withOpacity(.12),
        labelTextStyle: const MaterialStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _card,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: Colors.black12, thickness: 1),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
      splashColor: _primary.withOpacity(.08),
      highlightColor: Colors.transparent,
    );
  }
}
