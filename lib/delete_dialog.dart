import 'package:flutter/material.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/models/source.dart';
import 'package:fredstalker/error.dart';

class DeleteDialog extends StatefulWidget {
  final Source source;
  final Future<void> Function() ret;
  const DeleteDialog({super.key, required this.source, required this.ret});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm deletion"),
      content: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "You are about to delete source "),
            TextSpan(
              text: widget.source.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ", are you sure?"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await Error.tryAsyncNoLoading(
              () async => await Sql.deleteSource(widget.source.id!),
              context,
            );
            await widget.ret();
          },
          child: const Text("Confirm"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
