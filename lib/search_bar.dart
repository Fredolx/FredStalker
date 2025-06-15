import 'dart:async';

import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback toggleSearch;
  final Function(String) load;
  final bool hide;
  SearchBar({
    super.key,
    required this.searchController,
    required this.focusNode,
    required this.toggleSearch,
    required this.load,
    required this.hide,
  });
  Timer? _debounce;
  final FocusNode focusNode;
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: hide
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      focusNode: focusNode,
                      onChanged: (query) {
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            load(query);
                          },
                        );
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
                      onPressed: toggleSearch,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
