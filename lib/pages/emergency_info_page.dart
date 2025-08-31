import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// لو كان مسار الودجت مختلف عدّليه
import '../widgets/emergency_qr_card.dart';

class EmergencyInfoPage extends StatelessWidget {
  const EmergencyInfoPage({super.key, required this.nationalId});

  /// رقم الهوية الذي نبحث به عن المريض
  final String nationalId;

  SupabaseClient get _sb => Supabase.instance.client;

  // ========= بناء النص المضمّن داخل الـ QR =========
  String _buildQrPayload(_EmergencyDto d) {
    // نحرص يبدأ النص بحروف، عشان الكاميرا ما تعتبره رقم هاتف
    final pres = (d.prescriptions?.isNotEmpty == true)
        ? d.prescriptions!.join(', ')
        : 'None';
    return '''
EMERGENCY INFO
National ID: $nationalId
Blood Type: ${d.bloodGroup ?? 'None'}
Allergies: ${d.allergies ?? 'None'}
Conditions: ${d.chronicConditions ?? 'None'}
DNR: ${d.dnr ? 'Yes' : 'No'}
Prescriptions: $pres
'''
        .trim();
  }

  /// إظهار QR في BottomSheet مع حجم متجاوب
  void _showQrSheet(BuildContext context, String qrData) {
    final w = MediaQuery.of(context).size.width;
    final size = math.min(280.0, w * 0.72);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmergencyQrCard(
              emergencyLink: qrData, // نص بسيط (أوفلاين)
              title: 'Emergency QR (Offline)',
              subtitle: 'Scan to view summary (no internet required)',
              size: size,
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Keep the data short so the QR is easy to scan.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ========= جلب البيانات =========
  Future<_EmergencyDto?> _load() async {
    // 1) نجيب المريض عبر national_id للحصول على id الداخلي
    final patient = await _sb
        .from('create_user_patient')
        .select('id, full_name')
        .eq('national_id', nationalId.trim())
        .limit(1)
        .maybeSingle();

    if (patient == null) return null;

    final int patientId = (patient['id'] as num).toInt();
    final String? fullName = (patient['full_name'] as String?)?.trim();

    // 2) نجيب سجل الطوارئ المرتبط بـ patient_id
    final emg = await _sb.from('create_user_emergency').select('''
          allergies,
          blood_group,
          chronic_conditions,
          critical_notes,
          dnr,
          prescriptions
        ''').eq('patient_id', patientId).limit(1).maybeSingle();

    if (emg == null) {
      // لو ما فيه سجل طوارئ نرجّع على الأقل الاسم
      return _EmergencyDto(fullName: fullName);
    }

    String? _s(dynamic v) =>
        (v is String && v.trim().isNotEmpty) ? v.trim() : null;

    // prescriptions قد تكون نص مفصول بفواصل — نحوله لقائمة
    List<String>? _pres(dynamic v) {
      final raw = _s(v);
      if (raw == null) return null;
      return raw
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // dnr قد تكون yes/no أو true/false أو 0/1
    bool _dnr(dynamic v) {
      if (v is bool) return v;
      final s = (v ?? '').toString().toLowerCase().trim();
      return s == 'yes' || s == 'true' || s == '1';
    }

    return _EmergencyDto(
      fullName: fullName,
      bloodGroup: _s(emg['blood_group']),
      allergies: _s(emg['allergies']),
      chronicConditions: _s(emg['chronic_conditions']),
      criticalNotes: _s(emg['critical_notes']),
      dnr: _dnr(emg['dnr']),
      prescriptions: _pres(emg['prescriptions']),
    );
  }

  // ========= الواجهة =========
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Emergency Access'),
      ),
      body: FutureBuilder<_EmergencyDto?>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load data.\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final d = snap.data;
          if (d == null) {
            return Center(child: Text('No data found for ID: $nationalId'));
          }

          final payload = _buildQrPayload(d);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // Header + DNR
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        d.fullName ?? 'Emergency Info',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _DnrBadge(dnr: d.dnr),
                  ],
                ),
                const SizedBox(height: 8),

                // ---- VITALS ----
                Text(
                  'Vitals',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _vitalRow(
                  context,
                  icon: Icons.bloodtype_outlined,
                  iconColor: const Color(0xFFEB5757),
                  label: 'Blood Type',
                  value: d.bloodGroup ?? 'None',
                ),
                _vitalRow(
                  context,
                  icon: Icons.stacked_line_chart,
                  iconColor: const Color(0xFF2F80ED),
                  label: 'Chronic Conditions',
                  value: d.chronicConditions ?? 'None',
                ),
                _vitalRow(
                  context,
                  icon: Icons.medical_services_outlined,
                  iconColor: const Color(0xFFF2C94C),
                  label: 'Allergies',
                  value: (d.allergies == null || d.allergies!.isEmpty)
                      ? 'None'
                      : d.allergies!,
                ),

                const SizedBox(height: 16),
                const Divider(),

                // ---- Prescriptions ----
                const SizedBox(height: 8),
                Text(
                  'Prescriptions',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (d.prescriptions == null || d.prescriptions!.isEmpty)
                  _medRow(context, name: 'None')
                else
                  ...d.prescriptions!.map((m) => _medRow(context, name: m)),

                const SizedBox(height: 16),

                // ---- Critical Notes ----
                if ((d.criticalNotes ?? '').isNotEmpty) ...[
                  Text(
                    'Critical Notes',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(.08),
                      border: Border.all(color: Colors.orange.withOpacity(.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      d.criticalNotes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ---- QR Button ----
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Show Emergency QR'),
                    onPressed: () => _showQrSheet(context, payload),
                  ),
                ),

                const SizedBox(height: 16),

                // ---- Warning card ----
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.06),
                    border: Border.all(color: Colors.red.withOpacity(.25)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "This information is critical for emergency medical care.\nPlease ensure it's always up to date.",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- UI helpers ----------
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
}

class _EmergencyDto {
  _EmergencyDto({
    this.fullName,
    this.bloodGroup,
    this.allergies,
    this.chronicConditions,
    this.criticalNotes,
    this.dnr = false,
    this.prescriptions,
  });

  final String? fullName;
  final String? bloodGroup;
  final String? allergies;
  final String? chronicConditions;
  final String? criticalNotes;
  final bool dnr; // badge Yes/No
  final List<String>? prescriptions;
}

class _DnrBadge extends StatelessWidget {
  const _DnrBadge({required this.dnr});
  final bool dnr;

  @override
  Widget build(BuildContext context) {
    final color = dnr ? Colors.red : Colors.green;
    final text = dnr ? 'DNR: YES' : 'DNR: NO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
