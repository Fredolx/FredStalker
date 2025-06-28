import 'dart:core';

class Channel {
  final String? id;
  final String name;
  final String? image;
  final String? cmd;

  Channel({required this.name, this.image, this.cmd, this.id});
}
