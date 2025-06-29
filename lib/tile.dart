import 'package:cached_network_image/cached_network_image.dart';
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
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: widget.channel.image != null
                      ? CachedNetworkImage(
                          width: 1000,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) =>
                              Image.asset("assets/icon.png"),
                          imageUrl: widget.channel.image!,
                        )
                      : Image.asset("assets/icon.png", fit: BoxFit.contain),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 8,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final style = Theme.of(context).textTheme.bodyMedium!;
                    final fontSize = MediaQuery.of(
                      context,
                    ).textScaler.scale(style.fontSize!);
                    final lineHeight = style.height! * fontSize;
                    final maxLines = (constraints.maxHeight / lineHeight)
                        .floor();
                    return Text(
                      widget.channel.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: maxLines,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
