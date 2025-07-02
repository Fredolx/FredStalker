import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/media_type.dart';
import 'package:fredstalker/models/memory.dart';
import 'package:fredstalker/models/node.dart';
import 'package:fredstalker/models/node_type.dart';
import 'package:fredstalker/player.dart';
import 'package:fredstalker/error.dart';

class Tile extends StatefulWidget {
  const Tile({super.key, required this.channel, required this.setNode});
  final Function(Node node) setNode;
  final Channel channel;
  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  Future<void> play() async {
    if (widget.channel.mediaType != MediaType.live &&
        widget.channel.mediaType != MediaType.vod &&
        widget.channel.mediaType != MediaType.episode) {
      if (widget.channel.mediaType == MediaType.season) {
        Memory.stalker.setCurrentSeason(widget.channel);
      }
      widget.setNode(
        Node(
          id: widget.channel.id ?? "",
          name: widget.channel.name,
          type: fromMediaType(widget.channel.mediaType),
        ),
      );
      return;
    }
    Sql.addToHistory(widget.channel, Memory.stalker.sourceId);
    final channel = Channel(
      name: widget.channel.name,
      mediaType: widget.channel.mediaType,
      cmd: widget.channel.cmd,
      id: widget.channel.id,
    );
    await Error.tryAsync(
      () async {
        channel.cmd = await Memory.stalker.getLink(
          widget.channel.cmd!,
          widget.channel.mediaType,
          widget.channel.episodeNum,
        );
      },
      context,
      null,
      true,
      false,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Player(channel: channel)),
    );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Memory.stalker.favorites.containsKey(widget.channel.id)
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: play,
        onLongPress: () async {
          if (widget.channel.mediaType == MediaType.category ||
              widget.channel.mediaType == MediaType.series) {
            return;
          }
          if (!Memory.stalker.favorites.containsKey(widget.channel.id)) {
            await Memory.stalker.addFav(widget.channel);
          } else {
            await Memory.stalker.removeFav(widget.channel.id!);
          }
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
