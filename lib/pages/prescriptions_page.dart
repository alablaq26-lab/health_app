import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
import '../widgets.dart';
import 'visit_details_page.dart';

enum RxFilter { active, all }

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});
  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  RxFilter filter = RxFilter.active;
  String query = "";

  @override
  Widget build(BuildContext context) {
    final groups = prescriptionGroups.where((g) {
      final anyActive = g.meds.any((m) => !m.completed);
      final passesFilter = filter == RxFilter.all || anyActive;
      final matches = query.isEmpty ||
          g.meds.any((m) => m.name.toLowerCase().contains(query.toLowerCase()));
      return passesFilter && matches;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Prescriptions")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: "Search"),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          Segmented<RxFilter>(
            segments: const {RxFilter.active: "Active", RxFilter.all: "All"},
            value: filter,
            onChanged: (v) => setState(() => filter = v),
          ),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(children: const [
                Icon(Icons.medication_outlined,
                    size: 64, color: Colors.black26),
                SizedBox(height: 12),
                Text("No medicine for you, that's great.",
                    style: TextStyle(color: Colors.black54)),
              ]),
            )
          else
            for (final g in groups) _VisitPrescriptionCard(group: g),
        ],
      ),
    );
  }
}

class _VisitPrescriptionCard extends StatelessWidget {
  final PrescriptionGroup group;
  const _VisitPrescriptionCard({required this.group});

  @override
  Widget build(BuildContext context) {
    String niceDate =
        "${group.visit.at.day} ${_month(group.visit.at.month)} ${group.visit.at.year} at ${_hhmm(group.visit.at)}";
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(niceDate, style: const TextStyle(color: Colors.black54)),
            const Spacer(),
            TextButton(
              child: const Text("See Visit Details"),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => VisitDetailsPage(visit: group.visit))),
            ),
          ]),
          const SizedBox(height: 8),
          for (final m in group.meds) ...[
            Text(m.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text(m.instructions, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: m.completed ? 1 : .4,
                  backgroundColor: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.green.shade400,
                ),
              ),
              const SizedBox(width: 8),
              const Text("Completed", style: TextStyle(color: Colors.black54)),
            ]),
            const Divider(height: 24),
          ],
          Text("At ${group.visit.location}",
              style: const TextStyle(color: Colors.black45)),
        ]),
      ),
    );
  }

  String _month(int m) => [
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
  String _hhmm(DateTime d) =>
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} am";
}
