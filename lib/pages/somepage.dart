import 'package:flutter/material.dart';
import 'package:health_app/widgets/emergency_qr_card.dart';

class SomePage extends StatelessWidget {
  const SomePage({super.key});

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
          EmergencyQrCard(emergencyLink: _deepLink),
        ],
      ),
    );
  }
}
