import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Emergency page that shows: Blood Type, Chronic Conditions, Allergies,
/// and Current Medications.
/// - Reads from Supabase table: user_patient
/// - Uses: blood_group (for Blood Type)
/// - Allergies/Conditions/Medications are shown as "None" when not available.
///
/// NOTE: Make sure Supabase is initialized somewhere once in your app, e.g.:
/// (keep this as a comment if you already initialized it)
///
/// // await Supabase.initialize(
/// //   url: 'https://YOUR-PROJECT-ref.supabase.co',
/// //   anonKey: 'YOUR-ANON-KEY',
/// // );
///
class EmergencyInfoPage extends StatelessWidget {
  const EmergencyInfoPage({super.key, required this.nationalId});

  /// The citizen national ID to look up.
  final String nationalId;

  SupabaseClient get _sb => Supabase.instance.client;

  Future<_EmergencyDto?> _load() async {
    // 1) Try to get from user_patient by national_id
    final resp = await _sb
        .from('create_user_patient')
        .select('full_name, gender, dob, blood_group')
        .eq('national_id', nationalId.trim())
        .limit(1)
        .maybeSingle();

    if (resp == null) return null;

    // Map what we have. Missing fields will be "None" in the UI.
    final bloodGroup = (resp['blood_group'] as String?)?.trim();
    return _EmergencyDto(
      fullName: (resp['full_name'] as String?)?.trim(),
      bloodGroup:
          (bloodGroup == null || bloodGroup.isEmpty) ? null : bloodGroup,
      allergies: null, // Not available in user_patient → will show "None"
      chronicConditions: null, // Not available → "None"
      medications: const [], // Not available → "None"
    );
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
                child: Text(
                  'Failed to load data.\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final data = snap.data;
          if (data == null) {
            return Center(
              child: Text('No data found for ID: $nationalId'),
            );
          }

          return SafeArea(
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
                  value: data.bloodGroup ?? 'None',
                ),
                _vitalRow(
                  context,
                  icon: Icons.stacked_line_chart,
                  iconColor: const Color(0xFF2F80ED),
                  label: 'Chronic Conditions',
                  value: data.chronicConditions ?? 'None',
                ),
                _vitalRow(
                  context,
                  icon: Icons.medical_services_outlined,
                  iconColor: const Color(0xFFF2C94C),
                  label: 'Allergies',
                  value: (data.allergies == null || data.allergies!.isEmpty)
                      ? 'None'
                      : data.allergies!,
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
                if (data.medications == null || data.medications!.isEmpty)
                  _medRow(context, name: 'None')
                else
                  ...data.medications!.map(
                    (m) => _medRow(context, name: m),
                  ),

                const SizedBox(height: 16),

                // ---- WARNING CARD ----
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
    this.medications,
  });

  final String? fullName;
  final String? bloodGroup;
  final String? allergies;
  final String? chronicConditions;
  final List<String>? medications;
}
