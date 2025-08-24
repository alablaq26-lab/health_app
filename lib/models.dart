import 'package:flutter/material.dart';

enum AppointmentStatus { confirmed, pending, completed }

class Appointment {
  final String dept;
  final String hospital;
  final DateTime dateTime;
  final AppointmentStatus status;
  Appointment({
    required this.dept,
    required this.hospital,
    required this.dateTime,
    this.status = AppointmentStatus.confirmed,
  });
}

class Visit {
  final DateTime at;
  final String location;
  Visit({required this.at, required this.location});
}

class Medication {
  final String name;
  final String instructions;
  final bool completed;
  Medication(
      {required this.name, required this.instructions, this.completed = true});
}

class PrescriptionGroup {
  final Visit visit;
  final List<Medication> meds;
  PrescriptionGroup({required this.visit, required this.meds});
}

class LabTest {
  final String title;
  final Visit visit;
  final String doctor;
  final bool completed;
  final List<LabComponent> components;
  LabTest({
    required this.title,
    required this.visit,
    required this.doctor,
    required this.completed,
    required this.components,
  });
}

class LabComponent {
  final String name;
  final String value;
  final String range;
  final bool abnormal; // true = highlight
  LabComponent(
      {required this.name,
      required this.value,
      required this.range,
      this.abnormal = false});
}

class ProcedureItem {
  final Visit visit;
  final String title; // e.g., Nursing Procedure
  final List<String> notes; // timeline items
  ProcedureItem(
      {required this.visit, required this.title, required this.notes});
}

class Hospital {
  final String name;
  final String id;
  Hospital({required this.name, required this.id});
}

/// Simple badge for month/day used in lists.
class DateBadge extends StatelessWidget {
  final DateTime date;
  final Color color;
  const DateBadge(
      {super.key, required this.date, this.color = const Color(0xFF1976D2)});
  @override
  Widget build(BuildContext context) {
    final m = [
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
    ][date.month - 1];
    return Container(
      width: 54,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(m,
            style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text("${date.day}".padLeft(2, '0'),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
