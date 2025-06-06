import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/models/source.dart';
import 'package:fredstalker/error.dart';

class EditDialog extends StatefulWidget {
  final Source source;
  final Future<void> Function() ret;
  const EditDialog({super.key, required this.source, required this.ret});
  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text("Edit source ${widget.source.name}"),
          actions: [
            TextButton(
              onPressed: () async {
                if (!_formKey.currentState!.saveAndValidate()) {
                  return;
                }
                Navigator.of(context).pop();
                await Error.tryAsyncNoLoading(
                  () async => await Sql.updateSource(
                    Source(
                      id: widget.source.id,
                      name: widget.source.name,
                      url: _formKey.currentState?.value["url"],
                      mac: _formKey.currentState?.value["mac"],
                    ),
                  ),
                  context,
                );
                await widget.ret();
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
          content: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                FormBuilderTextField(
                  initialValue: widget.source.url,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  decoration: const InputDecoration(
                    labelText: 'Url',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                  name: 'url',
                ),
                const SizedBox(height: 30),
                FormBuilderTextField(
                  initialValue: widget.source.mac,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  decoration: const InputDecoration(
                    labelText: 'Mac Address',
                    prefixIcon: Icon(Icons.account_circle),
                    border: OutlineInputBorder(),
                  ),
                  name: 'mac',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
