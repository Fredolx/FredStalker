import 'package:flutter/material.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/memory.dart';

class Tile extends StatefulWidget {
  const Tile({super.key, required this.channel});
  final Channel channel;
  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Memory.stalker.favorites.containsKey(widget.channel.id)
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => {},
        onLongPress: () async {
          await Memory.stalker.addFav(widget.channel);
          setState(() {});
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(widget.channel.name),
        ),
      ),
    );
  }
}
