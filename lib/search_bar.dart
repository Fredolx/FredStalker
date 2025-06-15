import 'dart:async';

import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  SearchBar({
    super.key,
    required this.searchController,
    required this.hide,
    required this.focusNode,
  });
  Timer? _debounce;
  final FocusNode focusNode;
  bool hide = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: focusNode,
              onChanged: (query) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  // filters.query = query;
                  // load(false);
                  // call something on parent instead
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
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
