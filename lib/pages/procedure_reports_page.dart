import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';

enum ProcTab { all, media }

enum VisitTab { prescriptions, laboratory, radiology, procedure }

class ProcedureReportsPage extends StatefulWidget {
  const ProcedureReportsPage({super.key});
  @override
  State<ProcedureReportsPage> createState() => _ProcedureReportsPageState();
}

class _ProcedureReportsPageState extends State<ProcedureReportsPage> {
  ProcTab tab = ProcTab.all;
  String query = "";

  @override
  Widget build(BuildContext context) {
    final list = procedures
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Procedure Reports")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: "Search"),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          ToggleButtons(
            isSelected: [tab == ProcTab.all, tab == ProcTab.media],
            onPressed: (i) =>
                setState(() => tab = i == 0 ? ProcTab.all : ProcTab.media),
            borderRadius: BorderRadius.circular(10),
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("All")),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Media"))
            ],
          ),
          const SizedBox(height: 12),
          if (tab == ProcTab.media)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(children: const [
                Icon(Icons.description_outlined,
                    size: 64, color: Colors.black26),
                SizedBox(height: 12),
                Text("Could not find any procedure reports for you",
                    style: TextStyle(color: Colors.black54)),
              ]),
            )
          else
            for (final p in list) _ProcCard(item: p),
          const SizedBox(height: 8),
          if (list.isNotEmpty)
            Text("At ${list.first.visit.location}",
                style: const TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}

class _ProcCard extends StatelessWidget {
  final ProcedureItem item;
  const _ProcCard({required this.item});

  @override
  Widget build(BuildContext context) {
    String date =
        "${item.visit.at.day} ${_m(item.visit.at.month)} ${item.visit.at.year} at ${item.visit.at.hour}:${item.visit.at.minute.toString().padLeft(2, '0')} am";
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(date),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => _NursingBottomSheet(item: item),
        ),
      ),
    );
  }

  String _m(int m) => [
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
      ][m - 1];
}

class _NursingBottomSheet extends StatelessWidget {
  final ProcedureItem item;
  const _NursingBottomSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        minChildSize: .5,
        builder: (_, controller) => Column(
          children: [
            Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text(item.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share_outlined)),
              ]),
            ),
            const Divider(height: 0),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(item.notes[i]),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: item.notes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
