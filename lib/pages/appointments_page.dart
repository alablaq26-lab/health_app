import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Color status(AppointmentStatus s) {
      switch (s) {
        case AppointmentStatus.confirmed:
          return Colors.green;
        case AppointmentStatus.pending:
          return Colors.orange;
        case AppointmentStatus.completed:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Appointments"), actions: [
        TextButton(onPressed: () {}, child: const Text("Add Appointment"))
      ]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (c, i) {
          final a = appointments[i];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                  child: Icon(Icons.medical_services_outlined)),
              title: Text(a.dept,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text("${a.hospital}\n${a.dateTime}"),
              isThreeLine: true,
              trailing:
                  Icon(Icons.calendar_month_rounded, color: status(a.status)),
            ),
          );
        },
      ),
    );
  }
}
