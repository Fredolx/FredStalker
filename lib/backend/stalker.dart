import 'dart:collection';

import 'package:fredstalker/backend/exceptions/invalid_value_exception.dart';
import 'package:fredstalker/backend/sql.dart';
import 'package:fredstalker/models/channel.dart';
import 'package:fredstalker/models/filters.dart';
import 'package:fredstalker/models/media_type.dart';
import 'package:fredstalker/models/responses/categories_response.dart';
import 'package:fredstalker/models/responses/create_link.dart';
import 'package:fredstalker/models/responses/episodes.dart';
import 'package:fredstalker/models/responses/handshake.dart';
import 'package:fredstalker/models/responses/stream.dart';
import 'package:fredstalker/models/stalker_action.dart';
import 'package:fredstalker/models/stalker_result.dart';
import 'package:fredstalker/models/stalker_type.dart';
import 'package:fredstalker/models/view_type.dart';
import 'package:http/http.dart' as http;

class Stalker {
  static const List<String> potentialURLs = [
    "stalker_portal/server/load.php",
    "c/server/load.php",
    "portal.php",
  ];
  final int sourceId;
  Uri _url;
  final String _mac;
  Stream? _live;
  LinkedHashMap<String, Channel> favorites = LinkedHashMap();
  final HashMap<StalkerType, CategoriesResponse> _cats = HashMap();
  static const int maxItemsDefault = 14;

  Stalker(this._url, this._mac, this.sourceId);

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
      if (response.js?.token != null) {
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
    favorites = await Sql.getAllFavs(sourceId);
  }

  addBaseParams(String token) {
    _url = _url.replace(queryParameters: {"mac": _mac, "token": token});
  }

  Future<StalkerResult> getStreams(Filters filters) async {
    switch (filters.view) {
      case ViewType.all:
        return _getAll(filters);
      case ViewType.categories:
        return _getCats(filters);
      case ViewType.favorites:
        return _getFavs(filters);
      case ViewType.history:
        return _getHistory(filters);
      case ViewType.settings:
        throw InvalidValueException(filters.view.toString());
    }
  }

  Future<StalkerResult> _getHistory(Filters filters) async {
    final result = await Sql.getHistory(filters.query, sourceId);
    return StalkerResult(
      maxItemsDefault,
      result.$1,
      _getPageCount(result.$2, maxItemsDefault),
    );
  }

  Future<StalkerResult> _getCats(Filters filters) async {
    final result = StalkerResult(maxItemsDefault, List.empty(), 0);
    var currentCat = _cats[filters.type];
    if (currentCat == null) {
      _cats[filters.type] = await getCategories(filters.type);
      currentCat = _cats[filters.type];
    }
    Iterable<Category> catsTmp = currentCat!.js!;
    if (filters.query != null && filters.query!.isNotEmpty) {
      catsTmp = currentCat.js!.where(
        (x) => x.title!.toLowerCase().trim().contains(
          filters.query!.toLowerCase().trim(),
        ),
      );
    }
    result.maxPage = _getPageCount(catsTmp.length, maxItemsDefault);
    catsTmp = catsTmp
        .skip((filters.page - 1) * maxItemsDefault)
        .take(maxItemsDefault);
    result.channels = catsTmp.map(_getChannelFromCat).toList();
    return result;
  }

  _getPageCount(int itemsCount, int? maxItems) {
    return (itemsCount / (maxItems ?? maxItemsDefault)).ceil();
  }

  Future<void> addFav(Channel channel) async {
    await Sql.addFavorite(channel, sourceId);
    favorites[channel.id!] = channel;
  }

  Future<void> removeFav(String id) async {
    await Sql.removeFavorite(id, sourceId);
    favorites.remove(id);
  }

  Future<StalkerResult> _getFavs(Filters filters) async {
    Iterable<Channel> result = favorites.values;
    if (filters.query != null && filters.query!.isNotEmpty) {
      result = result.where((x) => x.name.contains(filters.query!));
    }
    final int count = result.length;
    result = result
        .skip((filters.page - 1) * maxItemsDefault)
        .take(maxItemsDefault);
    return StalkerResult(
      maxItemsDefault,
      result.toList(),
      _getPageCount(count, maxItemsDefault),
    );
  }

  Future<StalkerResult> _getAll(Filters filters) async {
    Stream stream;
    if (filters.type == StalkerType.live) {
      stream = await _getLive(filters);
    } else {
      stream = await _get(filters.type, StalkerAction.getList, {
        "p": filters.page.toString(),
        if (filters.categoryId != null) "category": filters.categoryId!,
        if (filters.categoryId != null) "genre": filters.categoryId!,
        if (filters.query != null) "search": filters.query!,
        if (filters.seriesId != null) "movie_id": filters.seriesId!,
      }, streamFromJson);
    }
    return _streamResponseToStalkerResult(
      stream,
      fromStalkerType(filters.type),
    );
  }

  Future<Stream> _getLive(Filters filters) async {
    _live ??= await _get(
      filters.type,
      StalkerAction.getAllChannels,
      {},
      streamFromJson,
    );
    final stream = Stream(js: StreamJs(maxPageItems: maxItemsDefault));
    Iterable<Data> data = _live!.js!.data!;
    if ((filters.query != null && filters.query!.isNotEmpty) ||
        filters.categoryId != null) {
      data = data.where(
        (x) =>
            (filters.query != null && filters.query!.isNotEmpty
                ? x.name!.toLowerCase().trim().contains(
                    filters.query!.toLowerCase().trim(),
                  )
                : true) &&
            (filters.categoryId != null
                ? x.tvGenreId == filters.categoryId
                : true),
      );
    }
    stream.js!.totalItems = data.length;
    stream.js!.data = data
        .skip((filters.page - 1) * maxItemsDefault)
        .take(maxItemsDefault)
        .toList();
    stream.js!.maxPageItems = maxItemsDefault;
    return stream;
  }

  Channel _getChannelFromCat(Category cat) {
    return Channel(name: cat.title!, id: cat.id, mediaType: MediaType.category);
  }

  StalkerResult _streamResponseToStalkerResult(
    Stream response,
    MediaType type,
  ) {
    return StalkerResult(
      response.js!.maxPageItems!,
      response.js!.data!
          .map((x) => _getChannelFromStreamItem(x, type))
          .toList(),
      (response.js!.totalItems! / response.js!.maxPageItems!).ceil(),
    );
  }

  Channel _getChannelFromStreamItem(Data data, MediaType type) {
    return Channel(
      id: data.id,
      cmd: data.cmd,
      image: data.screenshotUri ?? data.logo,
      name: data.name!,
      mediaType: type,
    );
  }

  Future<Episodes> getEpisodes(String id) async {
    return await _get(StalkerType.series, StalkerAction.getList, {
      "movie_id": id,
    }, episodesFromJson);
  }

  Future<String> getLink(String cmd, MediaType type, int? episode) async {
    var res = await _createLink(cmd, fromMediaType(type), episode);
    if (res.js?.cmd == null || res.js?.cmd?.isEmpty == true) {
      throw Exception("Couldn't play channel");
    }
    return res.js!.cmd!.split(" ").last;
  }

  Future<CreateLink> _createLink(
    String cmd,
    StalkerType type,
    int? episode,
  ) async {
    return await _get(type, StalkerAction.createLink, {
      "cmd": cmd,
      if (episode != null) "series": episode.toString(),
    }, createLinkFromJson);
  }

  Future<CategoriesResponse> getCategories(StalkerType type) async {
    return await _get(
      type,
      type == StalkerType.live
          ? StalkerAction.getGenres
          : StalkerAction.getCategories,
      {},
      categoriesFromJson,
    );
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
