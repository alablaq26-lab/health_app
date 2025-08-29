import 'package:flutter/material.dart';
import 'package:health_app/widgets/emergency_qr_card.dart';

class SomePage extends StatelessWidget {
  const SomePage({super.key});

  /// Put the user's national id here if you have it from DB/auth.
  final String? nationalId = '14509314';

  String get _deepLink {
    const base = 'healthapp://emergency';
    if (nationalId == null || nationalId!.isEmpty) return base;
    return '$base?nid=$nationalId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Your other widgets...

          /// The QR card widget we created
          EmergencyQrCard(emergencyLink: _deepLink),

          // Your other widgets...
        ],
      ),
    );
  }
}
