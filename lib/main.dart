import 'package:flutter/material.dart';
import 'package:fredstalker/home.dart';

void main() async {
  final hasSources = await Sql.hasSources();
  final settings = await SettingsService.getSettings();
  runApp(App(skipSetup: hasSources, settings: settings));
}

class App extends StatelessWidget {
  final bool skipSetup;
  final Settings settings;
  const App({super.key, required this.skipSetup, required this.settings});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fred Stalker',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const Home(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: skipSetup ? Home(settings: settings) : const Setup(),
    );
  }
}
