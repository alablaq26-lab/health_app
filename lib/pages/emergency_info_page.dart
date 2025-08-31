import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/emergency_qr_card.dart';

class EmergencyInfoPage extends StatelessWidget {
  const EmergencyInfoPage({super.key, required this.nationalId});

  final String nationalId;

  SupabaseClient get _sb => Supabase.instance.client;

  // نص موجز داخل QR (بدون أرقام هواتف)
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
      if ((d.criticalNotes ?? '').trim().isNotEmpty)
        'Notes: ${d.criticalNotes!.trim()}',
    ].join('\n');
  }

  void _showQrSheet(BuildContext context, String qrData) {
    final w = MediaQuery.of(context).size.width;
    final size = math.min(280.0, w * 0.72);
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: EmergencyQrCard(
          emergencyLink: qrData,
          title: 'Emergency QR (Offline)',
          subtitle: 'Scan to view summary (no internet required)',
          size: size,
        ),
      ),
    );
  }

  /// نجلب سجل الطوارئ عبر JOIN على create_user_patient بالنشنال آي دي
  Future<_EmergencyDto?> _load() async {
    try {
      final nid = nationalId.trim();
      debugPrint('🔎 [EmergencyInfoPage] nationalId="$nid"');

      final emg = await _sb
          .from('create_user_emergency')
          .select('''
            blood_group,
            allergies,
            chronic_conditions,
            critical_notes,
            dnr,
            prescriptions_section,
            create_user_patient!inner(id, national_id, full_name)
          ''')
          .eq('create_user_patient.national_id', nid)
          .limit(1)
          .maybeSingle();

      debugPrint('🧩 joined emergency row = $emg');
      if (emg == null) return null;

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

      final patient = emg['create_user_patient'] as Map<String, dynamic>?;

      return _EmergencyDto(
        fullName: (patient?['full_name'] as String?)?.trim(),
        bloodGroup: _s(emg['blood_group']),
        allergies: _s(emg['allergies']),
        chronicConditions: _s(emg['chronic_conditions']),
        criticalNotes: _s(emg['critical_notes']),
        dnr: _dnr(emg['dnr']),
        prescriptions: _s(emg['prescriptions_section']),
      );
    } on PostgrestException catch (e) {
      debugPrint(
          '❌ PostgrestException: ${e.code} ${e.message} details=${e.details} hint=${e.hint}');
      rethrow;
    } catch (e, st) {
      debugPrint('❌ Unknown error: $e\n$st');
      rethrow;
    }
  }

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
                child: Text('Failed to load data.\n${snap.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }

          final data = snap.data;
          if (data == null) {
            return Center(
                child: Text('No emergency data for ID: ${nationalId.trim()}'));
          }

          String n(String? v) => (v == null || v.trim().isEmpty) ? 'None' : v;
          final payload = _buildQrPayload(data);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Text('Vitals',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _vitalRow(context,
                    icon: Icons.bloodtype_outlined,
                    iconColor: const Color(0xFFEB5757),
                    label: 'Blood Type',
                    value: n(data.bloodGroup)),
                _vitalRow(context,
                    icon: Icons.stacked_line_chart,
                    iconColor: const Color(0xFF2F80ED),
                    label: 'Chronic Conditions',
                    value: n(data.chronicConditions)),
                _vitalRow(context,
                    icon: Icons.medical_services_outlined,
                    iconColor: const Color(0xFFF2C94C),
                    label: 'Allergies',
                    value: n(data.allergies)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text('Current Medications',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _medRow(context, name: n(data.prescriptions)),
                const SizedBox(height: 16),
                if ((data.criticalNotes ?? '').isNotEmpty) ...[
                  Text('Critical Notes',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(.06),
                      border: Border.all(color: Colors.orange.withOpacity(.25)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(data.criticalNotes!),
                  ),
                  const SizedBox(height: 16),
                ],
                _vitalRow(context,
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.red.shade600,
                    label: 'DNR',
                    value: n(data.dnr)),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Show Emergency QR (Offline)'),
                    onPressed: () => _showQrSheet(context, payload),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI helpers ---
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
          Text(value,
              style: textStyle?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right),
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
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (note != null) ...[
                  const SizedBox(width: 6),
                  Text(note,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54)),
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
    this.dnr,
    this.prescriptions,
  });

  final String? fullName;
  final String? bloodGroup;
  final String? allergies;
  final String? chronicConditions;
  final String? criticalNotes;
  final String? dnr; // Yes / No
  final String? prescriptions; // from prescriptions_section
}
