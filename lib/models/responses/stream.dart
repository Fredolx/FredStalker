// To parse this JSON data, do
//
//     final stream = streamFromJson(jsonString);

import 'dart:convert';

Stream streamFromJson(String str) => Stream.fromJson(json.decode(str));

String streamToJson(Stream data) => json.encode(data.toJson());

class Stream {
  StreamJs? js;

  Stream({this.js});

  factory Stream.fromJson(Map<String, dynamic> json) =>
      Stream(js: json["js"] == null ? null : StreamJs.fromJson(json["js"]));

  Map<String, dynamic> toJson() => {"js": js?.toJson()};
}

class StreamJs {
  int? totalItems;
  int? maxPageItems;
  int? selectedItem;
  int? curPage;
  List<Data>? data;

  StreamJs({
    this.totalItems,
    this.maxPageItems,
    this.selectedItem,
    this.curPage,
    this.data,
  });

  factory StreamJs.fromJson(Map<String, dynamic> json) => StreamJs(
    totalItems: json["total_items"],
    maxPageItems: json["max_page_items"],
    selectedItem: json["selected_item"],
    curPage: json["cur_page"],
    data: json["data"] == null
        ? []
        : List<Data>.from(json["data"]!.map((x) => Data.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total_items": totalItems,
    "max_page_items": maxPageItems,
    "selected_item": selectedItem,
    "cur_page": curPage,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Data {
  String? id;
  String? name;
  int? censored;
  String? cmd;
  String? logo;
  int? tvArchiveDuration;
  int? fav;
  int? archive;
  String? screenshotUri;
  String? categoryId;
  String? tvGenreId;
  List<int>? series;

  Data({
    this.id,
    this.name,
    this.censored,
    this.cmd,
    this.logo,
    this.tvArchiveDuration,
    this.fav,
    this.archive,
    this.screenshotUri,
    this.categoryId,
    this.tvGenreId,
    this.series,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    censored: json["censored"],
    cmd: json["cmd"],
    logo: json["logo"],
    tvArchiveDuration: json["tv_archive_duration"],
    fav: json["fav"],
    archive: json["archive"],
    screenshotUri: json["screenshot_uri"],
    categoryId: json["category_id"],
    tvGenreId: json["tv_genre_id"],
    series: json["series"] == null
        ? []
        : List<int>.from(json["series"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "censored": censored,
    "cmd": cmd,
    "logo": logo,
    "tv_archive_duration": tvArchiveDuration,
    "fav": fav,
    "archive": archive,
    "screenshot_uri": screenshotUri,
    "category_id": categoryId,
    "tv_genre_id": tvGenreId,
  };
}
