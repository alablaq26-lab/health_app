import 'package:flutter/material.dart';
import '../mock_data.dart';

class GovernmentHospitalsPage extends StatelessWidget {
  const GovernmentHospitalsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Government Hospitals")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final h in hospitals)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.apartment),
                title: Text(h.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(h.id),
                trailing: IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "Sync requested (updates within 24 hours)")));
                    }),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  "Could not find all of your linked institutes?\n\nPlease contact the medical records staff to link your patient ID with the civil ID."),
            ),
          ),
        ],
      ),
    );
  }
}
