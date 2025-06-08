import 'package:fredstalker/models/responses/create_link.dart';
import 'package:fredstalker/models/responses/episodes.dart';
import 'package:fredstalker/models/responses/handshake.dart';
import 'package:fredstalker/models/responses/stream.dart';
import 'package:fredstalker/models/stalker_action.dart';
import 'package:fredstalker/models/stalker_type.dart';
import 'package:http/http.dart' as http;

class Stalker {
  static const List<String> potentialURLs = [
    "stalker_portal/server/load.php",
    "c/server/load.php",
    "portal.php",
  ];
  Uri _url;
  final String _mac;

  Stalker(this._url, this._mac);

  Map<String, String> getHeaders() {
    return {
      "User-Agent":
          "Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 250 Safari/533.3",
      "X-User-Agent": "Model: MAG250; Link: WiFi",
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
    try {
      response = await _getToken(_mac);
      if (response?.js?.token != null) {
        return _url.toString();
      }
    } catch (e) {
      print("Initial URL (${_url.toString()}) failed: $e");
    }
    _url = _getBaseUrl(_url);
    for (var potentialURLEnding in potentialURLs) {
      _url = _url.replace(path: potentialURLEnding);
      try {
        response = await _getToken(_mac);
      } catch (e) {
        print("URL (${_url}) failed: $e");
      }
      if (response?.js?.token != null) {
        break;
      }
    }
    if (response?.js?.token == null) throw Exception("invalid url");
    return _url.toString();
  }

  Future<Handshake> _getToken(String mac) async {
    return await _get(StalkerType.stb, StalkerAction.handshake, {
      "mac": mac,
    }, handshakeFromJson);
  }

  Future<void> initialize() async {
    addBaseParams((await _getToken(_mac)).js!.token!);
  }

  addBaseParams(String token) {
    _url.replace(queryParameters: {"mac": _mac, "token": token});
  }

  Future<Stream> getStreams(int page, String search, StalkerType type) async {
    return await _get(type, StalkerAction.getList, {
      "search": search,
      "p": page.toString(),
    }, streamFromJson);
  }

  Future<Episodes> getEpisodes(String id) async {
    return await _get(StalkerType.series, StalkerAction.getList, {
      "movie_id": id,
    }, episodesFromJson);
  }

  Future<CreateLink> createLink(String cmd) async {
    return await _get(StalkerType.live, StalkerAction.createLink, {
      "cmd": cmd,
    }, createLinkFromJson);
  }

  Future<T> _get<T>(
    StalkerType type,
    StalkerAction action,
    Map<String, String> additionalParams,
    T Function(String) fromJson,
  ) async {
    var client = http.Client();
    final fUrl = _url.replace(
      queryParameters: {
        ..._url.queryParameters,
        "type": type.value,
        "action": action.value,
        ...additionalParams,
      },
    );
    var response = await client.get(fUrl, headers: getHeaders());
    return fromJson(response.body);
  }
}
