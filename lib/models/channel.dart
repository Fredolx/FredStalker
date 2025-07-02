import 'dart:collection';
import 'dart:core';

import 'package:fredstalker/models/media_type.dart';

class Channel {
  final String? id;
  final String name;
  final String? image;
  String? cmd;
  final MediaType mediaType;
  LinkedHashSet<int>? episodes;
  final int? episodeNum;

  Channel({
    required this.name,
    this.image,
    this.cmd,
    this.id,
    required this.mediaType,
    this.episodes,
    this.episodeNum,
  });
}
