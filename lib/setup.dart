import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/backend/utils.dart';
import 'package:fredstalker/home.dart';
import 'package:fredstalker/loading.dart';
import 'package:fredstalker/error.dart';
import 'package:fredstalker/models/source.dart';
import 'package:fredstalker/select.dart';

class Setup extends StatefulWidget {
  final bool showAppBar;
  const Setup({super.key, this.showAppBar = false});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool formValid = false;
  Set<String> existingSourceNames = {};

  showCorrectionModal() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Is this the right URL?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Proceed anyway"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Correct URL automatically"),
          ),
        ],
        content: const Text(
          "It seems your url is not pointing to a valid API server, Open TV can correct the URL automatically for you",
        ),
      ),
    );
  }

  Future<String> fixUrl(String url) async {
    var uri = Uri.parse(url);
    if (uri.scheme.isEmpty) {
      uri = Uri.parse("http://$uri");
    }
    if (uri.path == "/" || uri.path.isEmpty) {
      if (await showCorrectionModal()) {
        uri = uri.resolve(
          "player_api.php",
        ); //@TODO: Whatever stalker possibilities
      }
    }
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text("Adding a new source"))
          : null,
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
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                          labelText: 'URL', // Label inside the input
                          prefixIcon: Icon(
                            Icons.link,
                          ), // Icon inside the input (left side)
                          border: OutlineInputBorder(),
                        ),
                        name: 'url',
                      ),
                    ),
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
                          labelText: 'Mac',
                          prefixIcon: Icon(
                            Icons.account_circle, //@TODO: find better icon
                          ),
                          border: OutlineInputBorder(),
                        ),
                        name: 'username',
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
                        var url = _formKey.currentState?.value["url"] as String;
                        url = await fixUrl(url!);
                        final result = await Error.tryAsync(
                          () async {
                            await Utils.addSource(
                              Source(
                                name: sourceName,
                                url: url,
                                mac: _formKey.currentState?.value["username"],
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
      ),
    );
  }
}
