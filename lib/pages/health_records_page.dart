import 'package:flutter/material.dart';
import '../models.dart';

class HealthRecordsPage extends StatelessWidget {
  const HealthRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        "date": DateTime(2025, 7, 6),
        "title": "Dental",
        "subtitle":
            "outpatient | Saham Extended Health Center (PolyClinic)\nPulpitis",
        "color": const Color(0xFF1976D2)
      },
      {
        "date": DateTime(2025, 7, 6),
        "title": "General Practice",
        "subtitle":
            "outpatient | Saham Extended Health Center (PolyClinic)\nMedical care, unspecified",
        "color": const Color(0xFF1976D2)
      },
      {
        "date": DateTime(2025, 4, 18),
        "title": "General Practice",
        "subtitle":
            "outpatient | Saham Extended Health Center (PolyClinic)\nDental caries, unspecified",
        "color": const Color(0xFF1976D2)
      },
      {
        "date": DateTime(2023, 5, 30),
        "title": "General Practice",
        "subtitle":
            "outpatient | Saham Extended Health Center (PolyClinic)\nAcute tonsillitis, unspecified",
        "color": const Color(0xFF757575)
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Health Records")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: "Search")),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              children: ["All", "2025", "2023", "2022", "2021", "2020"]
                  .map((y) => ChoiceChip(label: Text(y), selected: y == "All"))
                  .toList()),
          const SizedBox(height: 12),
          for (final it in items)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  DateBadge(
                      date: it["date"] as DateTime,
                      color: it["color"] as Color),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(it["title"] as String,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(it["subtitle"] as String),
                      ])),
                  const Icon(Icons.chevron_right),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
