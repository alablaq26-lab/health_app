import 'package:flutter/material.dart';
import '../models.dart';

class LabTestDetailsPage extends StatelessWidget {
  final LabTest test;
  const LabTestDetailsPage({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(test.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(test.completed ? Icons.check_circle : Icons.info,
                  color: test.completed ? Colors.green : Colors.blue),
              title: Text(test.title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text("Ordered ${test.visit.at}\nBy ${test.doctor}"),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 8),
          if (test.components.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text("No components available for this test.",
                  style: TextStyle(color: Colors.grey.shade600)),
            )
          else
            DataTable(
              columns: const [
                DataColumn(label: Text("Components")),
                DataColumn(label: Text("Values")),
                DataColumn(label: Text("Range")),
              ],
              rows: [
                for (final c in test.components)
                  DataRow(cells: [
                    DataCell(Text(c.name)),
                    DataCell(Text(c.value,
                        style: TextStyle(
                            color: c.abnormal ? Colors.red : Colors.black))),
                    DataCell(Text(c.range)),
                  ]),
              ],
            ),
        ],
      ),
    );
  }
}
