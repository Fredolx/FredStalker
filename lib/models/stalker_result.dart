import 'package:fredstalker/models/channel.dart';

class StalkerResult {
  int maxItemsPerPage;
  int maxPage;
  List<Channel> channels;
  StalkerResult(this.maxItemsPerPage, this.channels, this.maxPage);
}
