import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fredstalker/backend/source_manager.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/loading.dart';
import 'package:fredstalker/error.dart';
import 'package:fredstalker/models/source.dart';
import 'package:fredstalker/select.dart';

class Setup extends StatefulWidget {
  const Setup({super.key});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool formValid = false;
  Set<String> existingSourceNames = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adding a new source"), elevation: 2),
      body: Loading(
        child: SafeArea(
          child: FormBuilder(
            onChanged: () {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  formValid = _formKey.currentState?.isValid == true;
                });
              });
            },
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        (value) {
                          var trimmed = value?.trim();
                          if (trimmed == null || trimmed.isEmpty) {
                            return null;
                          }
                          if (existingSourceNames.contains(trimmed)) {
                            return "Name already exists";
                          }
                          return null;
                        },
                      ]),
                      decoration: const InputDecoration(
                        labelText: 'Name', // Label inside the input
                        prefixIcon: Icon(
                          Icons.edit,
                        ), // Icon inside the input (left side)
                        border: OutlineInputBorder(),
                      ),
                      name: 'name',
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        prefixIcon: Icon(
                          Icons.link,
                        ), // Icon inside the input (left side)
                        border: OutlineInputBorder(),
                      ),
                      name: 'url',
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      decoration: const InputDecoration(
                        labelText: 'Mac Address',
                        prefixIcon: Icon(
                          Icons.account_circle, //@TODO: find better icon
                        ),
                        border: OutlineInputBorder(),
                      ),
                      name: 'mac',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: formValid
                          ? Colors.blue
                          : Colors.grey, // Disabled color
                      foregroundColor: Colors.white, // Text color
                    ),
                    onPressed: () async {
                      final sourceName =
                          (_formKey.currentState?.instantValue["name"]
                                  as String)
                              .trim();
                      if (await Sql.sourceNameExists(sourceName)) {
                        existingSourceNames.add(sourceName);
                      }
                      if (_formKey.currentState?.saveAndValidate() == false) {
                        return;
                      }
                      final result = await Error.tryAsync(
                        () async {
                          await SourceManager.addStalkerSource(
                            Source(
                              name: sourceName,
                              url:
                                  _formKey.currentState?.value["url"] as String,
                              mac: _formKey.currentState?.value["mac"],
                            ),
                          );
                        },
                        context,
                        "Successfully added source",
                      );
                      if (result.success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Select()),
                        );
                      }
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
