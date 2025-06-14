import 'package:flutter/material.dart';

class ArrowNav extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const ArrowNav({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left, size: 32),
          onPressed: onDecrement,
        ),
        Text('$value', style: const TextStyle(fontSize: 24)),
        IconButton(
          icon: const Icon(Icons.arrow_right, size: 32),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}
