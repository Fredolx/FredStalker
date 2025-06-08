// To parse this JSON data, do
//
//     final categories = categoriesFromJson(jsonString);

import 'dart:convert';

Categories categoriesFromJson(String str) =>
    Categories.fromJson(json.decode(str));

String categoriesToJson(Categories data) => json.encode(data.toJson());

class Categories {
  List<J>? js;

  Categories({this.js});

  factory Categories.fromJson(Map<String, dynamic> json) => Categories(
    js: json["js"] == null
        ? []
        : List<J>.from(json["js"]!.map((x) => J.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "js": js == null ? [] : List<dynamic>.from(js!.map((x) => x.toJson())),
  };
}

class J {
  String? id;
  String? title;

  J({this.id, this.title});

  factory J.fromJson(Map<String, dynamic> json) =>
      J(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
