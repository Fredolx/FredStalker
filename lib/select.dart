import 'package:flutter/material.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/loading.dart';
import 'package:fredstalker/models/source.dart';
import 'package:fredstalker/error.dart';
import 'package:fredstalker/source_tile.dart';

class Select extends StatefulWidget {
  const Select({super.key});

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  List<Source> sources = [];

  @override
  void initState() {
    super.initState();
    loadSources();
  }

  loadSources() async {
    await Error.tryAsyncNoLoading(
      () async => sources = await Sql.getSources(),
      context,
    );
    setState(() {
      sources;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a source"), elevation: 2),
      body: Loading(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              ...sources.map(
                (src) => SourceTile(source: src, ret: () => loadSources()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
