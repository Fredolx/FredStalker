import 'package:flutter/material.dart';
import 'package:fredstalker/models/view_type.dart';

class BottomNav extends StatefulWidget {
  final Function(ViewType) updateViewMode;
  final ViewType startingView;
  final bool blockSettings;
  const BottomNav({
    super.key,
    required this.updateViewMode,
    this.startingView = ViewType.all,
    this.blockSettings = false,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.startingView.index;
  }

  void onBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.updateViewMode(ViewType.values[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.surfaceBright,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Categories',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
        currentIndex: _selectedIndex,
        onTap: onBarTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
