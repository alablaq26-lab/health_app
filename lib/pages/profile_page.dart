import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
import '../widgets.dart';
import 'appointments_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        /// ✅ استبدلنا الهيدر بكرت ProfileHeaderCard الأزرق الجديد
        const ProfileHeaderCard(
          name: "Ali AL BREIKI",
          civilId: "15509334",
          ageYears: 25,
          bloodGroup: "A NEG",
          weightKg: 62,
          heightCm: 165,
          avatar: AssetImage('assets/user_placeholder.png'),
        ),
        const SizedBox(height: 16),

        // AI Analysis
        ExpansionTile(
          initiallyExpanded: false,
          leading:
              Icon(Icons.memory, color: Theme.of(context).colorScheme.primary),
          title: const Text("AI Analysis",
              style: TextStyle(fontWeight: FontWeight.w600)),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Risk Level: Very High",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text(
                          "Recommendation: Immediate medical consultation required"),
                    ]),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Scheduled Appointments
        ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(Icons.calendar_today_rounded,
              color: Theme.of(context).colorScheme.primary),
          title: const Text("Scheduled Appointments",
              style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.expand_more),
          children: [
            for (final a in appointments)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.medical_services_outlined),
                  title: Text("Appointment in ${a.dept}",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("${a.hospital}\n${a.dateTime}"),
                  isThreeLine: true,
                  trailing: Icon(Icons.circle,
                      size: 12, color: _statusColor(a.status)),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AppointmentsPage())),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
