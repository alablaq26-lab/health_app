import 'package:flutter/material.dart';
import '../models.dart';

class VisitDetailsPage extends StatefulWidget {
  final Visit visit;
  const VisitDetailsPage({super.key, required this.visit});

  /// Simple demo route for Vital Signs placeholder
  VisitDetailsPage.demoVitalSigns({super.key})
      : visit = Visit(at: null as dynamic, location: "");

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visit Details"),
        bottom: const TabBar(tabs: [
          Tab(text: "Prescriptions"),
          Tab(text: "Laboratory"),
          Tab(text: "Radiology"),
          Tab(text: "Procedure"),
        ]),
      ),
      body: TabBarView(controller: _tab, children: [
        _EmptyTab(
            icon: Icons.medication_outlined,
            text: "No prescriptions for this visit"),
        _EmptyTab(
            icon: Icons.biotech_outlined, text: "There are no laboratories"),
        _EmptyTab(icon: Icons.waves_outlined, text: "There are no radiologies"),
        _EmptyTab(
            icon: Icons.note_alt_outlined,
            text: "Nursing procedure details here"),
      ]),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyTab({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 72, color: Colors.black26),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: Colors.black54)),
      ]),
    );
  }
}
