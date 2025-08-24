import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
import '../widgets.dart';
import 'lab_test_details_page.dart';

enum LabFilter { recent, all }

class LabInvestigationsPage extends StatefulWidget {
  const LabInvestigationsPage({super.key});
  @override
  State<LabInvestigationsPage> createState() => _LabInvestigationsPageState();
}

class _LabInvestigationsPageState extends State<LabInvestigationsPage> {
  LabFilter filter = LabFilter.recent;
  String query = "";

  @override
  Widget build(BuildContext context) {
    final list = labTests
        .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Lab Investigations")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: "Search"),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          Segmented<LabFilter>(
            segments: const {LabFilter.recent: "Recent", LabFilter.all: "All"},
            value: filter,
            onChanged: (v) => setState(() => filter = v),
          ),
          const SizedBox(height: 12),
          Text("${_niceDate(list.first.visit.at)}",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text("See Visit Details"),
            ),
          ),
          for (final t in list)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(t.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle:
                    Text("Ordered ${_niceOrder(t.visit.at)}\nBy ${t.doctor}"),
                trailing: Icon(
                    t.completed ? Icons.check_circle : Icons.upload_rounded,
                    color: t.completed ? Colors.green : Colors.blue),
                isThreeLine: true,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LabTestDetailsPage(test: t))),
              ),
            ),
          const SizedBox(height: 8),
          Text("At ${list.first.visit.location}",
              style: const TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  String _niceDate(DateTime d) =>
      "${d.day} ${_m(d.month)} ${d.year} at ${d.hour}:${d.minute.toString().padLeft(2, '0')} am";
  String _niceOrder(DateTime d) =>
      "${d.day} ${_m(d.month)} ${d.year} at ${d.hour}:${d.minute.toString().padLeft(2, '0')} am";
  String _m(int m) => [
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
}
