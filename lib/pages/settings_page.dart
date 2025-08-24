import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool push = true;
  ThemeMode mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            value: push,
            onChanged: (v) => setState(() => push = v),
            title: const Text("Enable notifications"),
          ),
          ListTile(
            title: const Text("Language"),
            subtitle: const Text("Arabic / English"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Theme"),
            subtitle: Text(mode == ThemeMode.light ? "Light" : "Dark"),
            onTap: () => setState(() => mode =
                mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
          ),
          const Divider(),
          ListTile(
            title: const Text("Account"),
            subtitle: const Text("Update profile details, password"),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
