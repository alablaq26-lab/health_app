import 'package:flutter/material.dart';
import 'pages/profile_page.dart';
import 'pages/services_page.dart';
import 'pages/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [const ProfilePage(), const ServicesPage()];
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? "Home" : "Services"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: "Profile"),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined), label: "Services"),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
