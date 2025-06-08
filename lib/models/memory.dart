import 'package:fredstalker/backend/stalker.dart';
import 'package:fredstalker/models/source.dart';

class Memory {
  static Stalker? _currentSource;

  static Future<void> selectSource(Source source) async {
    var stalker = Stalker(Uri.parse(source.url), source.mac);
    await stalker.initialize();
    _currentSource = stalker;
  }
}
