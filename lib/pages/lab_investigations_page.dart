// lib/pages/lab_investigations_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ===================== Models (Top-level) =====================

class _Hospital {
  final int id;
  final String name;
  final String? branch;
  final String? type;
  const _Hospital({
    required this.id,
    required this.name,
    this.branch,
    this.type,
  });
}

class _LabRow {
  final int id; // result row id
  final String testName;
  final String? normalRange; // create_user_labtest.normal_range
  final String? resultValue; // create_user_labtestresult.result_value
  final DateTime orderedAt;
  final bool completed;

  // visit context
  final int visitId;
  final String doctorName;
  final String? doctorSpec;

  // hospital (for section footer)
  final int hospitalId;
  final String hospitalName;
  final String? hospitalBranch;
  final String? hospitalType;

  const _LabRow({
    required this.id,
    required this.testName,
    required this.normalRange,
    required this.resultValue,
    required this.orderedAt,
    required this.completed,
    required this.visitId,
    required this.doctorName,
    required this.doctorSpec,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalBranch,
    required this.hospitalType,
  });
}

class _Section {
  final DateTime date; // day (no time)
  final String label; // e.g., 31 Aug 2025
  final int visitId;
  final _Hospital hospital;
  final List<_LabRow> tests;
  const _Section({
    required this.date,
    required this.label,
    required this.visitId,
    required this.hospital,
    required this.tests,
  });
}

/// ===================== Page =====================

class LabInvestigationsPage extends StatefulWidget {
  const LabInvestigationsPage({super.key, required this.nationalId});
  final String nationalId;

  @override
  State<LabInvestigationsPage> createState() => _LabInvestigationsPageState();
}

class _LabInvestigationsPageState extends State<LabInvestigationsPage> {
  final _sb = Supabase.instance.client;

  String _query = '';
  bool _showRecent = true; // Recent | All
  final Map<int, bool> _expanded = {};

  // ---------- Load ----------
  Future<List<_Section>> _load() async {
    // 1) patient.id
    final p = await _sb
        .from('create_user_patient')
        .select('id')
        .eq('national_id', widget.nationalId.trim())
        .limit(1)
        .maybeSingle();
    if (p == null) return <_Section>[];
    final int patientId = (p['id'] as num).toInt();

    // 2) results
    final resRows = await _sb
        .from('create_user_labtestresult')
        .select(
            'id, result_value, result_date, lab_test_id, visit_id, patient_id')
        .eq('patient_id', patientId)
        .order('result_date', ascending: false);

    if (resRows.isEmpty) return <_Section>[];

    // IDs
    final labIds = <int>{};
    final visitIds = <int>{};
    for (final r in resRows) {
      final lid = (r['lab_test_id'] as num?)?.toInt();
      final vid = (r['visit_id'] as num?)?.toInt();
      if (lid != null) labIds.add(lid);
      if (vid != null) visitIds.add(vid);
    }

    // 3) lab tests map
    final Map<int, Map<String, String?>> labMap = {};
    if (labIds.isNotEmpty) {
      final labs = await _sb
          .from('create_user_labtest')
          .select('id, test_name, normal_range')
          .inFilter('id', labIds.toList());
      for (final l in labs) {
        final id = (l['id'] as num).toInt();
        labMap[id] = {
          'name': (l['test_name'] as String? ?? '').trim(),
          'range': (l['normal_range'] as String?)?.trim(),
        };
      }
    }

    // 4) visits map
    final Map<int, Map<String, dynamic>> visitMap = {};
    if (visitIds.isNotEmpty) {
      final vs = await _sb
          .from('create_user_visit')
          .select('visit_id, visit_date, doctor_id, hospital_id')
          .inFilter('visit_id', visitIds.toList());
      for (final v in vs) {
        final id = (v['visit_id'] as num).toInt();
        visitMap[id] = {
          'when': DateTime.tryParse(v['visit_date']?.toString() ?? ''),
          'doctor_id': (v['doctor_id'] as num?)?.toInt(),
          'hospital_id': (v['hospital_id'] as num?)?.toInt(),
        };
      }
    }

    // 5) doctors + hospitals
    final doctorIds = <int>{};
    final hospitalIds = <int>{};
    for (final v in visitMap.values) {
      final did = v['doctor_id'] as int?;
      final hid = v['hospital_id'] as int?;
      if (did != null) doctorIds.add(did);
      if (hid != null) hospitalIds.add(hid);
    }

    final Map<int, Map<String, String?>> doctorMap = {};
    if (doctorIds.isNotEmpty) {
      final drs = await _sb
          .from('create_user_doctor')
          .select('id, username, specialist')
          .inFilter('id', doctorIds.toList());
      for (final d in drs) {
        final id = (d['id'] as num).toInt();
        doctorMap[id] = {
          'name': (d['username'] as String? ?? '').trim(),
          'spec': (d['specialist'] as String?)?.trim(),
        };
      }
    }

    final Map<int, _Hospital> hospitalMap = {};
    if (hospitalIds.isNotEmpty) {
      final hs = await _sb
          .from('create_user_hospital')
          .select('hospital_id, hospital_name, hospital_branch, hospital_type')
          .inFilter('hospital_id', hospitalIds.toList());
      for (final h in hs) {
        final id = (h['hospital_id'] as num).toInt();
        hospitalMap[id] = _Hospital(
          id: id,
          name: (h['hospital_name'] as String? ?? '').trim(),
          branch: (h['hospital_branch'] as String?)?.trim(),
          type: (h['hospital_type'] as String?)?.trim(),
        );
      }
    }

    // 6) build rows
    final rows = <_LabRow>[];
    for (final r in resRows) {
      final int id = (r['id'] as num).toInt();
      final int? lid = (r['lab_test_id'] as num?)?.toInt();
      final int vid = (r['visit_id'] as num?)?.toInt() ?? 0;

      final visit = visitMap[vid];
      final when = DateTime.tryParse(r['result_date']?.toString() ?? '') ??
          (visit?['when'] as DateTime? ?? DateTime.now());
      final did = visit?['doctor_id'] as int?;
      final hid = visit?['hospital_id'] as int?;

      final lab = (lid != null) ? labMap[lid] : null;
      final testName = (lab?['name'] ?? '').isEmpty ? '—' : lab!['name']!;
      final normal = lab?['range'];

      final docName = (did != null) ? (doctorMap[did]?['name']) : null;
      final docSpec = (did != null) ? (doctorMap[did]?['spec']) : null;
      final hosp = (hid != null) ? hospitalMap[hid] : null;

      rows.add(_LabRow(
        id: id,
        testName: testName,
        normalRange: normal,
        resultValue: (r['result_value'] as String?)?.trim(),
        orderedAt: when,
        completed: true,
        visitId: vid,
        doctorName: (docName ?? '—'),
        doctorSpec: docSpec,
        hospitalId: hid ?? 0,
        hospitalName: hosp?.name ?? '—',
        hospitalBranch: hosp?.branch,
        hospitalType: hosp?.type,
      ));
    }

    // 7) search filter
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? rows
        : rows.where((t) => t.testName.toLowerCase().contains(q)).toList();

    // 8) recent = last day only
    List<_LabRow> base = filtered;
    if (_showRecent && filtered.isNotEmpty) {
      base.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
      final latest = base.first.orderedAt;
      base = base
          .where((t) =>
              t.orderedAt.year == latest.year &&
              t.orderedAt.month == latest.month &&
              t.orderedAt.day == latest.day)
          .toList();
    }

    // 9) group by day
    base.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
    final Map<String, List<_LabRow>> byDay = {};
    String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
    for (final r in base) {
      final k = dayKey(r.orderedAt);
      byDay.putIfAbsent(k, () => <_LabRow>[]).add(r);
    }

    final dfDay = DateFormat('d MMM yyyy');
    final List<_Section> sections = [];
    for (final e in byDay.entries) {
      final items = e.value..sort((a, b) => a.orderedAt.compareTo(b.orderedAt));
      final first = items.first;
      sections.add(
        _Section(
          date: DateTime(
              first.orderedAt.year, first.orderedAt.month, first.orderedAt.day),
          label: dfDay.format(first.orderedAt),
          visitId: first.visitId,
          hospital: _Hospital(
            id: first.hospitalId,
            name: first.hospitalName,
            branch: first.hospitalBranch,
            type: first.hospitalType,
          ),
          tests: items,
        ),
      );
    }

    sections.sort((a, b) => b.date.compareTo(a.date));
    return sections;
  }

  void _openVisit(int visitId) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Open visit #$visitId')));
  }

  void _toggleRow(int id) {
    setState(() => _expanded[id] = !(_expanded[id] ?? false));
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pri = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Lab Investigations')),
      body: FutureBuilder<List<_Section>>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load.\n${snap.error}'),
              ),
            );
          }

          final sections = snap.data ?? <_Section>[];
          if (sections.isEmpty) {
            return const Center(child: Text('No lab tests found.'));
          }

          final list = <Widget>[
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  filled: true,
                  fillColor: Colors.black12.withOpacity(.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            // Segments
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _Segment(
                      label: 'Recent',
                      selected: _showRecent,
                      onTap: () => setState(() => _showRecent = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Segment(
                      label: 'All',
                      selected: !_showRecent,
                      onTap: () => setState(() => _showRecent = false),
                    ),
                  ),
                ],
              ),
            ),
          ];

          for (final s in sections) {
            list.add(_SectionHeader(
              dateLabel: s.label,
              onSeeVisit: () => _openVisit(s.visitId),
            ));

            for (final t in s.tests) {
              final isOpen = _expanded[t.id] ?? false;
              list.add(
                Card(
                  elevation: 0,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _toggleRow(t.id),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title row
                          Row(
                            children: [
                              Icon(
                                t.completed
                                    ? Icons.check_circle
                                    : Icons.hourglass_bottom_rounded,
                                color: t.completed ? Colors.green : pri,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t.testName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // time + doctor (under test name)
                          Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 18, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('h:mm a').format(t.orderedAt),
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                              const SizedBox(width: 14),
                              Icon(Icons.person_outline,
                                  size: 18, color: Colors.black45),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'By ${t.doctorName}'
                                  '${(t.doctorSpec ?? '').isNotEmpty ? ' • ${t.doctorSpec}' : ''}',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // inline details
                          AnimatedCrossFade(
                            firstChild: const SizedBox(height: 0),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 18),
                                  _kvRow(
                                      context, 'Result', t.resultValue ?? '—'),
                                  _kvRow(context, 'Normal Range',
                                      t.normalRange ?? '—'),
                                ],
                              ),
                            ),
                            crossFadeState: isOpen
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 180),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // footer: hospital (only once per section)
            list.add(_SectionFooterHospital(
              hospitalName: s.hospital.name,
              branch: s.hospital.branch,
              type: s.hospital.type,
            ));
          }

          return ListView(children: list);
        },
      ),
    );
  }

  Widget _kvRow(BuildContext ctx, String key, String value) {
    final theme = Theme.of(ctx);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// ===================== UI Helpers =====================

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pri = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color:
              selected ? pri.withOpacity(.12) : Colors.black12.withOpacity(.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? pri : Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.dateLabel,
    required this.onSeeVisit,
  });

  final String dateLabel;
  final VoidCallback onSeeVisit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateLabel,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
              onPressed: onSeeVisit, child: const Text('See Visit Details')),
        ],
      ),
    );
  }
}

class _SectionFooterHospital extends StatelessWidget {
  const _SectionFooterHospital({
    required this.hospitalName,
    this.branch,
    this.type,
  });

  final String hospitalName;
  final String? branch;
  final String? type;

  @override
  Widget build(BuildContext context) {
    final tail = [
      if ((branch ?? '').isNotEmpty) branch,
      if ((type ?? '').isNotEmpty) type,
    ].join(' • ');
    final line = tail.isEmpty ? hospitalName : '$hospitalName ($tail)';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        'At $line',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.black45),
      ),
    );
  }
}
