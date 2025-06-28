import 'package:flutter/material.dart';

class ArrowNav extends StatelessWidget {
  final int value;
  final int? maxValue;
  final Function(bool) onDecrement;
  final Function(bool) onIncrement;

  const ArrowNav({
    super.key,
    required this.value,
    required this.maxValue,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        value != 1
            ? IconButton(
                icon: const Icon(Icons.arrow_left, size: 32),
                onPressed: () => onDecrement(false),
                onLongPress: () => onDecrement(true),
              )
            : SizedBox(width: 48),
        Text(getPageText(), style: const TextStyle(fontSize: 24)),
        IconButton(
          icon: const Icon(Icons.arrow_right, size: 32),
          onPressed: () => onIncrement(false),
          onLongPress: () => onIncrement(true),
        ),
      ],
    );
  }

  String getPageText() {
    return "$value / $maxValue";
  }
}
