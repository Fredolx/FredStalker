import 'package:flutter/material.dart';
import 'package:fredstalker/models/channel.dart';

class Tile extends StatefulWidget {
  const Tile({super.key, required this.channel});
  final Channel channel;
  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return Card(child: Center(child: Text(widget.channel.name)));
  }
}
