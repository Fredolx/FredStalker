import 'package:fredstalker/models/channel.dart';

class Season {
  String cmd;
  String name;
  List<Channel> episodes;
  Season({required this.cmd, required this.episodes, required this.name});
}
