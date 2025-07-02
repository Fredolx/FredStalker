import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Donate extends StatefulWidget {
  const Donate({super.key});

  @override
  State<Donate> createState() => _DonateState();
}

class _DonateState extends State<Donate> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(
          Uri.parse("https://github.com/Fredolx/FredStalker/discussions/1"),
        ),
        child: Text(
          style: TextStyle(
            color: Colors.blue,
            fontSize: 16,
            decoration: _isHovered
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
          "FredStalker needs your support. Consider donating today to keep the project alive!",
        ),
      ),
    );
  }
}
