import 'dart:core';

import 'package:fredstalker/models/media_type.dart';
import 'package:fredstalker/models/stalker_type.dart';

class Channel {
  final String? id;
  final String name;
  final String? image;
  final String? cmd;
  final MediaType mediaType;

  Channel({
    required this.name,
    this.image,
    this.cmd,
    this.id,
    required this.mediaType,
  });
}
