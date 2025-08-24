import 'package:flutter/material.dart';

class BloodDonationPage extends StatelessWidget {
  const BloodDonationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blood Donation")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.bloodtype, size: 40, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                      Text("One time donated blood in your life",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text("You can donate any time",
                          style: TextStyle(color: Colors.green)),
                    ])),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.water_drop, color: Colors.red),
              title: const Text("Whole Blood"),
              subtitle: const Text(
                  "Sohar Hospital, Suhar, Suhar Applied College\nTuesday, 2 May 2023 at 9:00 am"),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}
