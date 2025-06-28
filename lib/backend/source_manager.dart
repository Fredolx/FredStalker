import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/models/source.dart';
import 'package:fredstalker/backend/stalker.dart';

class SourceManager {
  static fixUrl(String url) {
    if (!url.startsWith("http://") || url.startsWith("https://")) {
      return "http://$url";
    }
    return url;
  }

  static Future<void> addStalkerSource(Source source) async {
    source.url = fixUrl(source.url);
    var stalker = Stalker(Uri.parse(source.url), source.mac, -1);
    source.url = await stalker.findUrl();
    await Sql.commitWrite([Sql.addSource(source)]);
  }
}
