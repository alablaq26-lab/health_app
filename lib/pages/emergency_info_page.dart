import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EmergencyInfoPage extends StatelessWidget {
  const EmergencyInfoPage({super.key});

  /// الرابط الذي سيُشفَّر داخل الـ QR (يمكن تغييره لاحقًا)
  static const String emergencyDeepLink = 'healthapp://emergency';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Emergency Access'),
        actions: [
          IconButton(
            tooltip: 'Show Emergency QR',
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => _showQrSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // ---- VITALS ----
            Text(
              'Vitals',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _vitalRow(
              context,
              icon: Icons.bloodtype_outlined,
              iconColor: const Color(0xFFEB5757),
              label: 'Blood Type',
              value: 'O+',
            ),
            _vitalRow(
              context,
              icon: Icons.stacked_line_chart,
              iconColor: const Color(0xFF2F80ED),
              label: 'Chronic Conditions',
              value: 'Diabetes Type 2',
            ),
            _vitalRow(
              context,
              icon: Icons.medical_services_outlined,
              iconColor: const Color(0xFFF2C94C),
              label: 'Allergies',
              value: 'Penicillin',
            ),

            const SizedBox(height: 16),
            const Divider(),

            // ---- CURRENT MEDS ----
            const SizedBox(height: 8),
            Text(
              'Current Medications',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _medRow(context, name: 'Metformin', note: '(daily)'),
            _medRow(context, name: 'Aspirin', note: '(daily)'),

            const SizedBox(height: 16),

            // ---- WARNING CARD ----
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.06),
                border: Border.all(color: Colors.red.withOpacity(.25)),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "This information is critical for emergency medical care.\nPlease ensure it's always up to date.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets helpers ----------

  Widget _vitalRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: textStyle)),
          Text(
            value,
            style: textStyle?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _medRow(BuildContext context, {required String name, String? note}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (note != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    note,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Bottom Sheet with QR ----------
  void _showQrSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Emergency QR',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
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
                  data: emergencyDeepLink,
                  version: QrVersions.auto,
                  size: 220,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Scan to open Emergency page',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
