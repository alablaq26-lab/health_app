import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Reusable card that shows an Emergency QR.
/// [emergencyLink] can be like: "healthapp://emergency" or "healthapp://emergency?nid=14509314"
class EmergencyQrCard extends StatelessWidget {
  const EmergencyQrCard({
    super.key,
    required this.emergencyLink,
    this.title = 'Emergency QR',
    this.subtitle = 'Scan to open Emergency page',
    this.size = 220,
  });

  final String emergencyLink;
  final String title;
  final String subtitle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: QrImageView(
                data: emergencyLink,
                version: QrVersions.auto,
                size: size,
              ),
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
