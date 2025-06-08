import 'package:fredstalker/models/responses/handshake.dart';
import 'package:http/http.dart' as http;

class Stalker {
  static const List<String> potentialURLs = [
    "",
    "stalker_portal/server/load.php",
    "c/server/load.php",
    "portal.php",
  ];
  String? _token;
  Uri _url;
  String _mac;

  Stalker(this._url, this._mac);

  Map<String, String> getHeaders() {
    return {
      "User-Agent":
          "Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 250 Safari/533.3X-User-Agent: Model: MAG250; Link: WiFi",
    };
  }

  Uri _getBaseUrl(Uri url) {
    return Uri(
      scheme: url.scheme,
      host: url.host,
      port: url.hasPort ? url.port : null,
    );
  }

  Future<String> findUrl() async {
    Handshake? response;
    _url = _getBaseUrl(_url);
    for (var potentialURLEnding in potentialURLs) {
      _url = _url.replace(path: potentialURLEnding);
      try {
        response = await _getToken();
      } catch (e) {
        //@Implement a good logging system
      }
      if (response != null) {
        break;
      }
    }
    if (response?.js?.token == null) throw Exception("invalid url");
    return _url.toString();
  }

  Future<Handshake> _getToken() async {
    var client = http.Client();
    final fUrl = _url.replace(
      queryParameters: {
        ..._url.queryParameters,
        "type": "stb",
        "action": "handshake",
      },
    );
    var response = await client.get(fUrl, headers: getHeaders());
    return handshakeFromJson(response.body);
  }

  Future<void> initialize() async {
    _token = (await _getToken()).js!.token;
  }
}
