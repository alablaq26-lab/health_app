import 'package:flutter/material.dart';
import '../widgets.dart';

class MedicalHistoryPage extends StatelessWidget {
  const MedicalHistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    Widget pill(String title, String hint, IconData icon) {
      return Card(
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.w700)),
          subtitle: Text(hint),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Medical History")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const SectionTitle(title: "Allergy", icon: Icons.ac_unit_outlined),
          pill(
              "Allergy",
              "It seems that you are not allergic to anything, thank God.",
              Icons.ac_unit_outlined),
          const SizedBox(height: 8),
          pill("Medical History", "Your medical history will appear here",
              Icons.description_outlined),
          const SizedBox(height: 8),
          pill("Final Diagnosis", "You’ll find the final diagnostics here",
              Icons.monitor_heart_outlined),
          const SizedBox(height: 8),
          pill("Referrals", "Your recent referrals appear here",
              Icons.swap_horiz),
        ],
      ),
    );
  }
}
