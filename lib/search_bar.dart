import 'dart:async';

import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) load;
  final VoidCallback back;
  final bool enabled;
  SearchBar({
    super.key,
    required this.searchController,
    required this.focusNode,
    required this.load,
    required this.enabled,
    required this.back,
  });
  final FocusNode focusNode;
  Timer? _debounce;

  void clear() {
    if (searchController.text == "") return;
    searchController.clear();
    load("");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Row(
        children: [
          IconButton(onPressed: back, icon: Icon(Icons.arrow_back)),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              enabled: enabled,
              controller: searchController,
              focusNode: focusNode,
              onChanged: (query) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  load(query);
                });
              },
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true, // Light background for contrast
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: enabled ? clear : null,
            icon: Icon(
              Icons.backspace_outlined,
              color: enabled
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
