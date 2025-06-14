import 'package:fredstalker/models/channel.dart';

class StalkerResult {
  int maxItemsPerPage;
  List<Channel> channels;
  StalkerResult(this.maxItemsPerPage, this.channels);
}
