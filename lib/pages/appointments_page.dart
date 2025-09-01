import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final _sb = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  late int _patientId;
  List<_Appt> _appts = [];
  Map<int, _Doctor> _doctors = {};
  Map<int, _Hospital> _hospitals = {};

  @override
  void initState() {
    super.initState();
    _load();
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

      // 1) get patient
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

      // 2) appointments
      final rows = await _sb
          .from('create_user_appointment')
          .select(
              'appointment_id, appointment_date, status, notes, doctor_id, hospital_id')
          .eq('patient_id', _patientId)
          .order('appointment_date', ascending: true);

      final appts = <_Appt>[];
      final doctorIds = <int>{};
      final hospitalIds = <int>{};

      for (final r in rows as List) {
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

      // 3) doctors
      final Map<int, _Doctor> doctorsMap = {};
      if (doctorIds.isNotEmpty) {
        final drs = await _sb
            .from('create_user_doctor')
            .select('id, username, specialist')
            .inFilter('id', doctorIds.toList());
        for (final d in drs as List) {
          final id = (d['id'] as num).toInt();
          doctorsMap[id] = _Doctor(
            id: id,
            name: (d['username'] as String? ?? 'Doctor').trim(),
            specialist: (d['specialist'] as String? ?? 'General').trim(),
          );
        }
      }

      // 4) hospitals
      final Map<int, _Hospital> hospitalsMap = {};
      if (hospitalIds.isNotEmpty) {
        final hs = await _sb
            .from('create_user_hospital')
            .select(
                'hospital_id, hospital_name, hospital_branch, hospital_type')
            .inFilter('hospital_id', hospitalIds.toList());
        for (final h in hs as List) {
          final id = (h['hospital_id'] as num).toInt();
          hospitalsMap[id] = _Hospital(
            id: id,
            name: (h['hospital_name'] as String? ?? 'Hospital').trim(),
            branch: (h['hospital_branch'] as String?)?.trim(),
            type: (h['hospital_type'] as String?)?.trim(),
          );
        }
      }

      setState(() {
        _loading = false;
        _appts = appts;
        _doctors = doctorsMap;
        _hospitals = hospitalsMap;
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

  String _doctorLine(_Appt a) {
    final d = _doctors[a.doctorId];
    if (d == null) return 'Doctor: —';
    return d.specialist.isEmpty
        ? 'Dr. ${d.name}'
        : 'Dr. ${d.name} • ${d.specialist}';
  }

  String _hospitalLine(_Appt a) {
    final h = _hospitals[a.hospitalId];
    if (h == null) return 'Hospital: —';
    final tail = [
      if ((h.branch ?? '').isNotEmpty) h.branch,
      if ((h.type ?? '').isNotEmpty) h.type,
    ].join(' • ');
    return tail.isEmpty ? h.name : '${h.name} • $tail';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointments')),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(16), child: Text(_error!))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Appointments")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appts.length,
        itemBuilder: (c, i) {
          final a = _appts[i];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                  child: Icon(Icons.medical_services_outlined)),
              title: Text(_doctorLine(a),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text("${_hospitalLine(a)}\n${a.when}"),
              isThreeLine: true,
              trailing: Icon(Icons.calendar_month_rounded,
                  color: _statusColor(a.status)),
            ),
          );
        },
      ),
    );
  }
}

class _Appt {
  final int id;
  final DateTime when;
  final String status;
  final int doctorId;
  final int hospitalId;
  final String? notes;
  _Appt({
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
  _Doctor({required this.id, required this.name, required this.specialist});
}

class _Hospital {
  final int id;
  final String name;
  final String? branch;
  final String? type;
  _Hospital({required this.id, required this.name, this.branch, this.type});
}
