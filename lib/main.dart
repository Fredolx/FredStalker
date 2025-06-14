import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/select.dart';
import 'package:fredstalker/setup.dart';

class ProxyHttpOverrides extends HttpOverrides {
  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    return 'PROXY localhost:9090';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = ProxyHttpOverrides();
  final hasSources = await Sql.hasSources();
  runApp(App(skipSetup: hasSources));
}

class App extends StatelessWidget {
  final bool skipSetup;
  const App({super.key, required this.skipSetup});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fred Stalker',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: skipSetup ? Select() : const Setup(),
    );
  }
}
