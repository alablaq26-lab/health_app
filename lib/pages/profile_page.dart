import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;

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
  final String riskLevel;
  final double? probability;
  final String? recommendation;
  final DateTime? date;
  const _AiSummary({
    required this.riskLevel,
    this.probability,
    this.recommendation,
    this.date,
  });
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.nationalId});
  final String nationalId;

  SupabaseClient get _sb => Supabase.instance.client;

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

  Future<
      (
        _Patient?,
        List<_Appt>,
        Map<int, _Doctor>,
        Map<int, _Hospital>,
        _AiSummary?
      )> _load() async {
    final nid = nationalId.trim();

    final p = await _sb
        .from('create_user_patient')
        .select(
            'id, national_id, full_name, gender, dob, blood_group, height, weight')
        .eq('national_id', nid)
        .limit(1)
        .maybeSingle();

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

    double? _f(dynamic v) => v == null ? null : (v as num).toDouble();

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
    final violet = theme.colorScheme.primary;

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
              child: Text('No profile found for ID: ${nationalId.trim()}'));
        }

        final age = _age(patient.dob);
        final info = <(IconData, String)>[
          (Icons.badge_outlined, patient.nationalId),
          (
            Icons.monitor_weight_outlined,
            '${(patient.weight ?? 0).toStringAsFixed(0)} kg'
          ),
          (Icons.straighten, '${(patient.height ?? 0).toStringAsFixed(0)} cm'),
          (Icons.bloodtype_outlined, (patient.bloodGroup ?? '—')),
          (Icons.cake_outlined, age == null ? '—' : '${age}Y'),
          (Icons.transgender, patient.gender.isEmpty ? '—' : patient.gender),
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _ProfileHeader(
              name: patient.name,
              items: info,
              backgroundColor: violet,
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              leading: Icon(Icons.memory, color: violet),
              title: Text('AI Analysis',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: violet,
                  )),
              children: [
                Card(
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
                                      : violet,
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
                                Text('Recommendation: ${ai.recommendation!}'),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              leading: Icon(Icons.calendar_today_rounded, color: violet),
              title: Text('Scheduled Appointments',
                  style: TextStyle(fontWeight: FontWeight.w600, color: violet)),
              children: [
                if (appts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text('No appointments found.'),
                  )
                else
                  for (final a in appts)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.medical_services_outlined),
                        title: Text(
                          (() {
                            final d = doctorsMap[a.doctorId];
                            if (d == null) return 'Doctor: —';
                            return d.specialist.isEmpty
                                ? 'Dr. ${d.name}'
                                : 'Dr. ${d.name} • ${d.specialist}';
                          })(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          (() {
                            final h = hospitalsMap[a.hospitalId];
                            if (h == null) return _fmtDate(a.when);
                            final tail = [
                              if ((h.branch ?? '').isNotEmpty) h.branch,
                              if ((h.type ?? '').isNotEmpty) h.type,
                            ].join(' • ');
                            final hn =
                                tail.isEmpty ? h.name : '${h.name} • $tail';
                            return '$hn\n${_fmtDate(a.when)}';
                          })(),
                        ),
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.items,
    required this.backgroundColor,
  });

  final String name;
  final List<(IconData, String)> items;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pattern = _MedicalPattern(color: Colors.white.withOpacity(.08));

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(.95),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: pattern,
        child: LayoutBuilder(
          builder: (ctx, c) {
            final avatar = CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم يلف ولا يسبب Overflow
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // الأيقونات والقيم: 3 عناصر في السطر تلقائيًا
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        children: [
                          for (final (icon, text) in items)
                            _InfoItem(icon: icon, text: text),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// رسمة باترن خفيف (أيقونات طبية) — بدون أي Overflow
class _MedicalPattern extends CustomPainter {
  _MedicalPattern({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const icons = <IconData>[
      Icons.medication_outlined,
      Icons.local_hospital_outlined,
      Icons.bloodtype_outlined,
      Icons.biotech_outlined,
      Icons.vaccines_outlined,
      Icons.monitor_heart_outlined,
      Icons.emergency_outlined,
      Icons.science_outlined,
      Icons.spa_outlined,
    ];

    const gap = 34.0;
    const iconSize = 18.0;

    for (double y = 10; y < size.height; y += gap) {
      for (double x = 10; x < size.width; x += gap) {
        final icon = icons[((x + y) ~/ gap) % icons.length];
        final tp = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: iconSize,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: color,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MedicalPattern old) => old.color != color;
}
