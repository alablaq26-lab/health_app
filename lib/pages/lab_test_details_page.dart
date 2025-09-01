import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LabTestDetailsPage extends StatefulWidget {
  const LabTestDetailsPage({
    super.key,
    required this.resultId,
    this.titleHint,
    this.doctorHint,
    this.hospitalHint,
    this.orderedAtHint,
  });

  final int resultId;
  final String? titleHint;
  final String? doctorHint;
  final String? hospitalHint;
  final DateTime? orderedAtHint;

  @override
  State<LabTestDetailsPage> createState() => _LabTestDetailsPageState();
}

class _LabTestDetailsPageState extends State<LabTestDetailsPage> {
  final _sb = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  String title = 'Lab Test';
  String? doctorName;
  String? hospitalName;
  DateTime? orderedAt;

  String? resultValue;
  String? notes;

  @override
  void initState() {
    super.initState();
    title = widget.titleHint ?? title;
    doctorName = widget.doctorHint;
    hospitalName = widget.hospitalHint;
    orderedAt = widget.orderedAtHint;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) نتيجة الفحص
      final row = await _sb
          .from('create_user_labtestresult')
          .select('id, lab_test_id, result_value, result_date, notes, visit_id')
          .eq('id', widget.resultId)
          .maybeSingle();

      if (row == null) {
        setState(() {
          _loading = false;
          _error = 'Result not found';
        });
        return;
      }

      resultValue = (row['result_value'] as String?)?.trim();
      notes = (row['notes'] as String?)?.trim();

      // 2) اسم الاختبار
      final testId = (row['lab_test_id'] as num?)?.toInt();
      if (testId != null) {
        final t = await _sb
            .from('create_user_labtest')
            .select('test_name')
            .eq('id', testId)
            .maybeSingle();
        if (t != null) title = (t['test_name'] as String? ?? title).trim();
      }

      final vid = (row['visit_id'] as num?)?.toInt();
      if (vid != null) {
        final v = await _sb
            .from('create_user_visit')
            .select('visit_date, doctor_id, hospital_id')
            .eq('visit_id', vid)
            .maybeSingle();

        if (v != null) {
          orderedAt ??= DateTime.tryParse(v['visit_date']?.toString() ?? '');
          final did = (v['doctor_id'] as num?)?.toInt();
          final hid = (v['hospital_id'] as num?)?.toInt();

          if (did != null && (doctorName == null || doctorName!.isEmpty)) {
            final d = await _sb
                .from('create_user_doctor')
                .select('username')
                .eq('id', did)
                .maybeSingle();
            if (d != null)
              doctorName = (d['username'] as String? ?? 'Doctor').trim();
          }
          if (hid != null && (hospitalName == null || hospitalName!.isEmpty)) {
            final h = await _sb
                .from('create_user_hospital')
                .select('hospital_name, hospital_branch')
                .eq('hospital_id', hid)
                .maybeSingle();
            if (h != null) {
              final n = (h['hospital_name'] as String? ?? 'Hospital').trim();
              final b = (h['hospital_branch'] as String?)?.trim();
              hospitalName = (b == null || b.isEmpty) ? n : '$n ($b)';
            }
          }
        }
      }

      orderedAt ??= DateTime.tryParse(row['result_date']?.toString() ?? '');

      setState(() {
        _loading = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _loading = false;
        _error = 'Database error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Unexpected error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final when = orderedAt == null ? '-' : _niceOrder(orderedAt!);
    final by = (doctorName ?? '-');

    return Scaffold(
      appBar: AppBar(title: Text("🔬 $title")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    Card(
                      child: ListTile(
                        leading: Icon(
                          (resultValue != null && resultValue!.isNotEmpty)
                              ? Icons.check_circle
                              : Icons.upload_rounded,
                          color:
                              (resultValue != null && resultValue!.isNotEmpty)
                                  ? Colors.green
                                  : Colors.blue,
                        ),
                        title: Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text("Ordered $when\nBy $by"),
                        isThreeLine: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Results",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _kv(
                                "Value",
                                resultValue?.isNotEmpty == true
                                    ? resultValue!
                                    : "-"),
                            if ((notes ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _kv("Notes", notes!),
                            ],
                            if ((hospitalName ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text("At $hospitalName",
                                  style:
                                      const TextStyle(color: Colors.black45)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$k: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(v)),
      ],
    );
  }

  String _niceOrder(DateTime d) =>
      "${_two(d.day)} ${_m(d.month)} ${d.year} at ${_hmm(d)}";

  String _m(int m) => const [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ][m - 1];

  String _hmm(DateTime d) {
    final h = d.hour;
    final m = _two(d.minute);
    final ampm = h >= 12 ? "pm" : "am";
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return "$h12:$m $ampm";
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
