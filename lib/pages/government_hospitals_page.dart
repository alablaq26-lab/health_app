import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GovernmentHospitalsPage extends StatefulWidget {
  const GovernmentHospitalsPage({super.key});
  @override
  State<GovernmentHospitalsPage> createState() =>
      _GovernmentHospitalsPageState();
}

class _GovernmentHospitalsPageState extends State<GovernmentHospitalsPage> {
  final _sb = Supabase.instance.client;

  bool _loading = true;
  String? _error;
  int? _patientId;

  List<_Hospital> _linked = [];
  List<_Hospital> _allGov = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final nid = (prefs.getString('national_id') ?? '').trim();
      if (nid.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No saved National ID. Please sign in again.';
        });
        return;
      }

      final p = await _sb
          .from('create_user_patient')
          .select('id')
          .eq('national_id', nid)
          .limit(1)
          .maybeSingle();

      if (p == null) {
        setState(() {
          _loading = false;
          _error = 'No patient found for ID: $nid';
        });
        return;
      }
      _patientId = (p['id'] as num).toInt();

      final pid = _patientId!;

      final gov = await _sb
          .from('create_user_hospital')
          .select('hospital_id, hospital_name, hospital_branch, hospital_type')
          .ilike('hospital_type', 'government%');

      final allGov = <_Hospital>[];
      for (final h in gov as List) {
        allGov.add(_Hospital(
          id: (h['hospital_id'] as num).toInt(),
          name: (h['hospital_name'] as String? ?? 'Hospital').trim(),
          branch: (h['hospital_branch'] as String?)?.trim(),
          type: (h['hospital_type'] as String?)?.trim(),
        ));
      }

      final linkedIds = <int>{};

      // appointments
      final ap = await _sb
          .from('create_user_appointment')
          .select('hospital_id')
          .eq('patient_id', pid);

      for (final r in ap as List) {
        final hid = (r['hospital_id'] as num?)?.toInt();
        if (hid != null) linkedIds.add(hid);
      }

      // visits
      final vs = await _sb
          .from('create_user_visit')
          .select('hospital_id')
          .eq('patient_id', pid);

      for (final r in vs as List) {
        final hid = (r['hospital_id'] as num?)?.toInt();
        if (hid != null) linkedIds.add(hid);
      }

      final linked = allGov.where((h) => linkedIds.contains(h.id)).toList();
      final rest = allGov.where((h) => !linkedIds.contains(h.id)).toList();

      setState(() {
        _loading = false;
        _linked = linked;
        _allGov = rest;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Government Hospitals")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16), child: Text(_error!)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_linked.isNotEmpty) ...[
                      const Text("Linked to your records",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      for (final h in _linked) _hCard(h),
                      const SizedBox(height: 16),
                    ],
                    const Text("All Government Hospitals",
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    for (final h in _allGov) _hCard(h),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.blue.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Could not find all of your linked institutes?\n\n"
                          "Please contact the medical records staff to link your patient ID with the civil ID.",
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _hCard(_Hospital h) {
    final tail = [
      if ((h.branch ?? '').isNotEmpty) h.branch,
      if ((h.type ?? '').isNotEmpty) h.type,
    ].join(' • ');
    final subtitle = tail.isEmpty ? 'ID: ${h.id}' : 'ID: ${h.id}\n$tail';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.apartment),
        title:
            Text(h.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _Hospital {
  final int id;
  final String name;
  final String? branch;
  final String? type;
  _Hospital({required this.id, required this.name, this.branch, this.type});
}
