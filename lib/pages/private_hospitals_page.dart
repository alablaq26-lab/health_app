import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';

class PrivateHospitalsPage extends StatelessWidget {
  const PrivateHospitalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = privateHospitalsVisited; // من mock_data.dart

    return Scaffold(
      appBar: AppBar(title: const Text('Private Hospitals')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black12.withOpacity(.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Could not find all of your linked institutes?\n\n"
                "Please contact the medical records staff to link your patient ID with the civil ID.",
                style: TextStyle(fontSize: 16),
              ),
            )
          else
            ...items.map(
              (Hospital h) => Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.local_hospital,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(h.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(h.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
