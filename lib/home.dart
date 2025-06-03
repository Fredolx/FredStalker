import 'package:flutter/material.dart';
import 'package:fredstalker/models/settings.dart';

class Home extends StatefulWidget {
  final Settings settings;
  const Home({super.key, required this.settings});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(),
    );
  }
}
