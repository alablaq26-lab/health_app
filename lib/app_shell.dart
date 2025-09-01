import 'package:flutter/material.dart';
import 'pages/profile_page.dart';
import 'pages/services_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.nationalId});
  final String nationalId;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ProfilePage(nationalId: widget.nationalId),
      ServicesPage(nationalId: widget.nationalId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? "Home" : "Services"),
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: "Profile"),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined), label: "Services"),
        ],
      ),
    );
  }
}
