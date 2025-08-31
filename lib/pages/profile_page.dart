import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Patient {
  final int id;
  final String name;
  final String gender;
  final String nationalId;
  final DateTime? dob;
  final String? bloodGroup;
  final double? height;
  final double? weight;
  const _Patient({
    required this.id,
    required this.name,
    required this.gender,
    required this.nationalId,
    this.dob,
    this.bloodGroup,
    this.height,
    this.weight,
  });
}

class _Appt {
  final int id;
  final DateTime when;
  final String status;
  final int doctorId;
  final int hospitalId;
  final String? notes;
  const _Appt({
    required this.id,
    required this.when,
    required this.status,
    required this.doctorId,
    required this.hospitalId,
    this.notes,
  });
}

class _Doctor {
  final int id;
  final String name;
  final String specialist;
  const _Doctor(
      {required this.id, required this.name, required this.specialist});
}

class _Hospital {
  final int id;
  final String name;
  final String? branch;
  final String? type;
  const _Hospital(
      {required this.id, required this.name, this.branch, this.type});
}

class _AiSummary {
  final String riskLevel; // High/Very High/...
  final double? probability; // 0..1
  final String? recommendation;
  final DateTime? date;
  const _AiSummary(
      {required this.riskLevel,
      this.probability,
      this.recommendation,
      this.date});
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.nationalId});
  final String nationalId;

  SupabaseClient get _sb => Supabase.instance.client;

  // -------- Helpers --------
  int? _age(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var a = now.year - dob.year;
    final hadBirthday = (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthday) a--;
    return a;
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _fmtDate(DateTime dt) => DateFormat('yyyy-MM-dd • HH:mm').format(dt);

  // -------- Load all needed data --------
  Future<
      (
        _Patient?, // $1
        List<_Appt>, // $2
        Map<int, _Doctor>, // $3
        Map<int, _Hospital>, // $4
        _AiSummary? // $5
      )> _load() async {
    final nid = nationalId.trim();

    // 1) Patient
    final p = await _sb.from('create_user_patient').select('''
          id, national_id, full_name, gender, dob, blood_group, height, weight
        ''').eq('national_id', nid).limit(1).maybeSingle();

    if (p == null) {
      return (null, <_Appt>[], <int, _Doctor>{}, <int, _Hospital>{}, null);
    }

    DateTime? _parseDate(dynamic v) {
      try {
        if (v == null) return null;
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    double? _f(dynamic v) {
      if (v == null) return null;
      return (v as num).toDouble();
    }

    final patient = _Patient(
      id: (p['id'] as num).toInt(),
      nationalId: (p['national_id'] as String? ?? '').trim(),
      name: (p['full_name'] as String? ?? '').trim(),
      gender: (p['gender'] as String? ?? '').trim(),
      dob: _parseDate(p['dob']),
      bloodGroup: (p['blood_group'] as String?)?.trim(),
      height: _f(p['height']),
      weight: _f(p['weight']),
    );

    // 2) Appointments
    final apRows = await _sb
        .from('create_user_appointment')
        .select(
            'appointment_id, appointment_date, status, notes, doctor_id, hospital_id')
        .eq('patient_id', patient.id)
        .order('appointment_date', ascending: true);

    final appts = <_Appt>[];
    final doctorIds = <int>{};
    final hospitalIds = <int>{};

    for (final r in apRows) {
      final did = (r['doctor_id'] as num?)?.toInt() ?? 0;
      final hid = (r['hospital_id'] as num?)?.toInt() ?? 0;
      doctorIds.add(did);
      hospitalIds.add(hid);

      final dtStr = r['appointment_date']?.toString();
      final when = dtStr != null
          ? (DateTime.tryParse(dtStr) ?? DateTime.now())
          : DateTime.now();

      appts.add(_Appt(
        id: (r['appointment_id'] as num?)?.toInt() ?? 0,
        when: when,
        status: (r['status'] as String? ?? 'pending').trim(),
        doctorId: did,
        hospitalId: hid,
        notes: (r['notes'] as String?)?.trim(),
      ));
    }

    // 3) Doctors
    final Map<int, _Doctor> doctorsMap = {};
    if (doctorIds.isNotEmpty) {
      final drs = await _sb
          .from('create_user_doctor')
          .select('id, username, specialist')
          .inFilter('id', doctorIds.toList());

      for (final d in drs) {
        final id = (d['id'] as num).toInt();
        doctorsMap[id] = _Doctor(
          id: id,
          name: (d['username'] as String? ?? 'Doctor').trim(),
          specialist: (d['specialist'] as String? ?? 'General').trim(),
        );
      }
    }

    // 4) Hospitals (المفتاح اسمه hospital_id)
    final Map<int, _Hospital> hospitalsMap = {};
    if (hospitalIds.isNotEmpty) {
      final hs = await _sb
          .from('create_user_hospital')
          .select('hospital_id, hospital_name, hospital_branch, hospital_type')
          .inFilter('hospital_id', hospitalIds.toList());

      for (final h in hs) {
        final id = (h['hospital_id'] as num).toInt();
        hospitalsMap[id] = _Hospital(
          id: id,
          name: (h['hospital_name'] as String? ?? 'Hospital').trim(),
          branch: (h['hospital_branch'] as String?)?.trim(),
          type: (h['hospital_type'] as String?)?.trim(),
        );
      }
    }

    // 5) AI summary (أحدث سجل للمريض)
    _AiSummary? ai;
    final aiRow = await _sb
        .from('ai_engine_predictionresult')
        .select('probability, risk_level, recommendation, prediction_date')
        .eq('patient_id', patient.id)
        .order('prediction_date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (aiRow != null) {
      ai = _AiSummary(
        riskLevel: (aiRow['risk_level'] as String? ?? '—').trim(),
        probability: (aiRow['probability'] as num?)?.toDouble(),
        recommendation: (aiRow['recommendation'] as String?)?.trim(),
        date: _parseDate(aiRow['prediction_date']),
      );
    }

    return (patient, appts, doctorsMap, hospitalsMap, ai);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<
        (
          _Patient?,
          List<_Appt>,
          Map<int, _Doctor>,
          Map<int, _Hospital>,
          _AiSummary?
        )>(
      future: _load(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load profile.\n${snap.error}',
                  textAlign: TextAlign.center),
            ),
          );
        }

        final patient = snap.data!.$1;
        final appts = snap.data!.$2;
        final doctorsMap = snap.data!.$3;
        final hospitalsMap = snap.data!.$4;
        final ai = snap.data!.$5;

        if (patient == null) {
          return Center(
            child: Text('No profile found for ID: ${nationalId.trim()}'),
          );
        }

        String _doctorLine(_Appt a) {
          final d = doctorsMap[a.doctorId];
          if (d == null) return 'Doctor: —';
          return d.specialist.isEmpty
              ? 'Dr. ${d.name}'
              : 'Dr. ${d.name} • ${d.specialist}';
        }

        String _hospitalLine(_Appt a) {
          final h = hospitalsMap[a.hospitalId];
          if (h == null) return 'Hospital: —';
          final tail = [
            if ((h.branch ?? '').isNotEmpty) h.branch,
            if ((h.type ?? '').isNotEmpty) h.type,
          ].join(' • ');
          return tail.isEmpty ? h.name : '${h.name} • $tail';
        }

        final age = _age(patient.dob);
        final headerChips = <String>[
          'Civil ID: ${patient.nationalId}',
          if (age != null) 'Age: $age',
          if ((patient.bloodGroup ?? '').isNotEmpty)
            'Blood: ${patient.bloodGroup}',
          if (patient.height != null)
            'Height: ${patient.height!.toStringAsFixed(0)} cm',
          if (patient.weight != null)
            'Weight: ${patient.weight!.toStringAsFixed(0)} kg',
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // ===== Blue Header: الصورة + الاسم + الجنس + بقية المعلومات المطلوبة =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/user_placeholder.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patient.gender.isEmpty ? '—' : patient.gender,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in headerChips)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  s,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== AI Analysis (مربوط من قاعدة البيانات) =====
            ExpansionTile(
              initiallyExpanded: false,
              leading: Icon(Icons.memory, color: theme.colorScheme.primary),
              title: const Text('AI Analysis',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ai == null
                        ? const Text('No AI analysis available.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Risk Level: ${ai.riskLevel}',
                                style: TextStyle(
                                  color: (ai.riskLevel
                                          .toLowerCase()
                                          .contains('high'))
                                      ? Colors.red
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (ai.probability != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                    'Probability: ${(ai.probability! * 100).toStringAsFixed(1)}%'),
                              ],
                              if (ai.date != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                    'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(ai.date!)}'),
                              ],
                              if ((ai.recommendation ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Recommendation:${ai.recommendation!}'),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ===== Scheduled Appointments (مربوطة) =====
            ExpansionTile(
              initiallyExpanded: true,
              leading: Icon(Icons.calendar_today_rounded,
                  color: theme.colorScheme.primary),
              title: const Text('Scheduled Appointments',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              children: [
                if (appts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text('No appointments found.'),
                  )
                else
                  for (final a in appts)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.medical_services_outlined),
                        title: Text(
                          _doctorLine(a),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle:
                            Text('${_hospitalLine(a)}\n${_fmtDate(a.when)}'),
                        isThreeLine: true,
                        trailing: Icon(Icons.circle,
                            size: 12, color: _statusColor(a.status)),
                      ),
                    ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _hospitalLine(_Appt a, Map<int, _Hospital> hospitalsMap) {
    final h = hospitalsMap[a.hospitalId];
    if (h == null) return 'Hospital: —';
    final tail = [
      if ((h.branch ?? '').isNotEmpty) h.branch,
      if ((h.type ?? '').isNotEmpty) h.type,
    ].join(' • ');
    return tail.isEmpty ? h.name : '${h.name} • $tail';
  }
}
