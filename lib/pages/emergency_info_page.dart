import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/emergency_qr_card.dart';

class EmergencyInfoPage extends StatelessWidget {
  const EmergencyInfoPage({super.key, required this.nationalId});
  final String nationalId;

  SupabaseClient get _sb => Supabase.instance.client;

  String _buildQrPayload(_EmergencyDto d) {
    String n(String? v) => (v == null || v.trim().isEmpty) ? 'None' : v.trim();
    return [
      'EMERGENCY INFO',
      'National ID: ${nationalId.trim()}',
      'Blood: ${n(d.bloodGroup)}',
      'Allergies: ${n(d.allergies)}',
      'Conditions: ${n(d.chronicConditions)}',
      if ((d.prescriptions ?? '').trim().isNotEmpty)
        'Meds: ${d.prescriptions!.trim()}',
      'DNR: ${n(d.dnr)}',
    ].join('\n');
  }

  // 🔧 التعديل الوحيد هنا لإزالة overflow
  void _showQrSheet(BuildContext context, String qrData) {
    final w = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true, // يسمح للـ sheet بارتفاع أكبر ويمنع القص
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => LayoutBuilder(
        builder: (ctx, cons) {
          // احسب حجم QR بما لا يتجاوز المساحة المتاحة داخل الـ sheet
          // اطرح هامش بسيط لتجنب أي تماس مع الحواف السفلية
          final safeMax = (cons.maxHeight.isFinite ? cons.maxHeight : 400) - 72;
          final size = math.max(
              160.0, // حد أدنى معقول للوضوح
              math.min(280.0, math.min(w * 0.72, safeMax)).toDouble());
          // تأكد من أنه double
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: EmergencyQrCard(
              emergencyLink: qrData,
              title: 'Emergency QR (Offline)',
              subtitle: 'Scan to view summary (no internet required)',
              size: size,
            ),
          );
        },
      ),
    );
  }

  Future<_EmergencyDto?> _load() async {
    try {
      final nid = nationalId.trim();

      final p = await _sb
          .from('create_user_patient')
          .select('id, full_name')
          .eq('national_id', nid)
          .limit(1)
          .maybeSingle();

      if (p == null) return null;

      final int patientId = (p['id'] as num).toInt();
      final String? fullName = (p['full_name'] as String?)?.trim();

      // 2) emergency record for that patient
      final emg = await _sb.from('create_user_emergency').select('''
            blood_group, allergies, chronic_conditions, dnr, prescriptions_section
          ''').eq('patient_id', patientId).limit(1).maybeSingle();

      if (emg == null) return _EmergencyDto(fullName: fullName);

      String? _s(dynamic v) {
        final s = v as String?;
        if (s == null) return null;
        final t = s.trim();
        return t.isEmpty ? null : t;
      }

      String? _dnr(dynamic v) {
        final t = (v as String?)?.trim().toLowerCase();
        if (t == null || t.isEmpty) return null;
        return (t == 'yes' || t == 'y' || t == 'true') ? 'Yes' : 'No';
      }

      return _EmergencyDto(
        fullName: fullName,
        bloodGroup: _s(emg['blood_group']),
        allergies: _s(emg['allergies']),
        chronicConditions: _s(emg['chronic_conditions']),
        dnr: _dnr(emg['dnr']),
        prescriptions: _s(emg['prescriptions_section']),
      );
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException: ${e.message}');
      rethrow;
    } catch (e, st) {
      debugPrint('Unknown error: $e\n$st');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String n(String? v) => (v == null || v.trim().isEmpty) ? 'None' : v;

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
                child: Text('Failed to load data.\n${snap.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final data = snap.data;
          if (data == null) {
            return Center(
                child: Text('No data found for ID: ${nationalId.trim()}'));
          }

          final payload = _buildQrPayload(data);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Header card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vitals', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 10),
                        _vitalRow(
                          context,
                          icon: Icons.bloodtype_outlined,
                          iconColor: const Color(0xFFEB5757),
                          label: 'Blood Type',
                          value: n(data.bloodGroup),
                        ),
                        _vitalRow(
                          context,
                          icon: Icons.stacked_line_chart,
                          iconColor: const Color(0xFF2F80ED),
                          label: 'Chronic Conditions',
                          value: n(data.chronicConditions),
                        ),
                        _vitalRow(
                          context,
                          icon: Icons.medical_services_outlined,
                          iconColor: const Color(0xFFF2C94C),
                          label: 'Allergies',
                          value: n(data.allergies),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Medications',
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 10),
                        _medRow(context, name: n(data.prescriptions)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _vitalRow(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          iconColor: Colors.red.shade600,
                          label: 'DNR',
                          value: n(data.dnr),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Show Emergency QR (Offline)'),
                    onPressed: () => _showQrSheet(context, payload),
                  ),
                ),

                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "This information is critical for emergency medical care. "
                            "Please ensure it's always up to date.",
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // UI
  Widget _vitalRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
    this.dnr,
    this.prescriptions,
  });

  final String? fullName;
  final String? bloodGroup;
  final String? allergies;
  final String? chronicConditions;
  final String? dnr;
  final String? prescriptions;
}
