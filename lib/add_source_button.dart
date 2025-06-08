import 'package:flutter/material.dart';
import 'package:fredstalker/setup.dart';

class AddSourceButton extends StatefulWidget {
  const AddSourceButton({super.key});
  @override
  State<AddSourceButton> createState() => _AddSourceButtonState();
}

class _AddSourceButtonState extends State<AddSourceButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isHovered
          ? const Color.fromARGB(255, 29, 150, 34)
          : Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: _isHovered ? 10 : 5,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: add,
          child: Padding(
            padding: EdgeInsetsGeometry.all(15),
            child: Center(child: Icon(Icons.add, size: 30)),
          ),
        ),
      ),
    );
  }

  add() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Setup()));
  }
}
