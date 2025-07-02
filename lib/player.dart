import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/media_type.dart';
import 'package:fredstalker/models/memory.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkvideo;

class Player extends StatefulWidget {
  final Channel channel;
  const Player({super.key, required this.channel});
  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late mk.Player player = mk.Player();
  late StreamSubscription<Duration> subscription;
  late mkvideo.VideoController videoController = mkvideo.VideoController(
    player,
  );
  late final GlobalKey<VideoState> key = GlobalKey<VideoState>();
  @override
  void initState() {
    super.initState();
    mk.MediaKit.ensureInitialized();
    initAsync();
  }

  Future<void> initAsync() async {
    final seconds =
        widget.channel.mediaType == MediaType.vod ||
            widget.channel.mediaType == MediaType.episode
        ? await Sql.getPosition(widget.channel.id!, Memory.stalker.sourceId)
        : null;
    await player.open(
      mk.Media(
        widget.channel.cmd!,
        start: seconds != null ? Duration(seconds: seconds) : null,
      ),
    );
    player.setPlaylistMode(mk.PlaylistMode.single);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MaterialDesktopVideoControlsTheme(
        normal: getThemeData(context),
        fullscreen: getThemeData(context),
        child: Video(key: key, controller: videoController),
      ),
    );
  }

  MaterialDesktopVideoControlsThemeData getThemeData(BuildContext context) {
    return MaterialDesktopVideoControlsThemeData(
      displaySeekBar: widget.channel.mediaType != MediaType.live,
      topButtonBar: [
        IconButton(
          onPressed: () {
            if (widget.channel.mediaType == MediaType.vod ||
                widget.channel.mediaType == MediaType.episode) {
              Sql.setPosition(
                widget.channel.id!,
                player.state.position.inSeconds,
                Memory.stalker.sourceId,
              );
            }
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 10),
        Text(widget.channel.name),
      ],
    );
  }
}
