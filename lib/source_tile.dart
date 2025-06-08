import 'package:flutter/material.dart';
import 'package:fredstalker/delete_dialog.dart';
import 'package:fredstalker/edit_dialog.dart';
import 'package:fredstalker/home.dart';
import 'package:fredstalker/models/memory.dart';
import 'package:fredstalker/models/source.dart';
import 'package:fredstalker/error.dart';

class SourceTile extends StatefulWidget {
  final Source source;
  final Future<void> Function() ret;
  const SourceTile({super.key, required this.source, required this.ret});
  @override
  State<SourceTile> createState() => _SourceTileState();
}

class _SourceTileState extends State<SourceTile> {
  bool _isHovered = false;

  showEditDialog(BuildContext context, final Source source) async {
    await showDialog(
      context: context,
      builder: (builder) => EditDialog(source: source, ret: widget.ret),
    );
  }

  showConfirmDeleteDialog(Source source) async {
    await showDialog(
      context: context,
      builder: (builder) => DeleteDialog(source: source, ret: widget.ret),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isHovered
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: _isHovered ? 10 : 5,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: select,
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 20),
            title: Text(widget.source.name),
            subtitle: Text(widget.source.url),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async =>
                      await showEditDialog(context, widget.source),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async =>
                      await showConfirmDeleteDialog(widget.source),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> select() async {
    var result = await Error.tryAsyncNoLoading(() async {
      await Memory.selectSource(widget.source);
    }, context);
    if (result.success)
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }
}
