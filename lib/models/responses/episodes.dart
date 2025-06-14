// To parse this JSON data, do
//
//     final episodes = episodesFromJson(jsonString);

import 'dart:convert';

Episodes episodesFromJson(String str) => Episodes.fromJson(json.decode(str));

String episodesToJson(Episodes data) => json.encode(data.toJson());

class Episodes {
  EpisodesJs? js;

  Episodes({this.js});

  factory Episodes.fromJson(Map<String, dynamic> json) =>
      Episodes(js: json["js"] == null ? null : EpisodesJs.fromJson(json["js"]));

  Map<String, dynamic> toJson() => {"js": js?.toJson()};
}

class EpisodesJs {
  int? totalItems;
  int? maxPageItems;
  int? selectedItem;
  int? curPage;
  List<EpisodesData>? data;

  EpisodesJs({
    this.totalItems,
    this.maxPageItems,
    this.selectedItem,
    this.curPage,
    this.data,
  });

  factory EpisodesJs.fromJson(Map<String, dynamic> json) => EpisodesJs(
    totalItems: json["total_items"],
    maxPageItems: json["max_page_items"],
    selectedItem: json["selected_item"],
    curPage: json["cur_page"],
    data: json["data"] == null
        ? []
        : List<EpisodesData>.from(
            json["data"]!.map((x) => EpisodesData.fromJson(x)),
          ),
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

class EpisodesData {
  String? id;
  String? name;
  String? description;
  List<int>? series;
  String? categoryId;
  String? director;
  String? actors;
  DateTime? year;
  int? accessed;
  int? status;
  DateTime? added;
  String? screenshotUri;
  String? genresStr;
  String? cmd;

  EpisodesData({
    this.id,
    this.name,
    this.description,
    this.series,
    this.categoryId,
    this.director,
    this.actors,
    this.year,
    this.accessed,
    this.status,
    this.added,
    this.screenshotUri,
    this.genresStr,
    this.cmd,
  });

  factory EpisodesData.fromJson(Map<String, dynamic> json) => EpisodesData(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    series: json["series"] == null
        ? []
        : List<int>.from(json["series"]!.map((x) => x)),
    categoryId: json["category_id"],
    director: json["director"],
    actors: json["actors"],
    year: json["year"] == null ? null : DateTime.parse(json["year"]),
    accessed: json["accessed"],
    status: json["status"],
    added: json["added"] == null ? null : DateTime.parse(json["added"]),
    screenshotUri: json["screenshot_uri"],
    genresStr: json["genres_str"],
    cmd: json["cmd"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "series": series == null ? [] : List<dynamic>.from(series!.map((x) => x)),
    "category_id": categoryId,
    "director": director,
    "actors": actors,
    "year":
        "${year!.year.toString().padLeft(4, '0')}-${year!.month.toString().padLeft(2, '0')}-${year!.day.toString().padLeft(2, '0')}",
    "accessed": accessed,
    "status": status,
    "added": added?.toIso8601String(),
    "screenshot_uri": screenshotUri,
    "genres_str": genresStr,
    "cmd": cmd,
  };
}
