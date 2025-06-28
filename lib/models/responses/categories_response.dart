// To parse this JSON data, do
//
//     final categories = categoriesFromJson(jsonString);

import 'dart:convert';

CategoriesResponse categoriesFromJson(String str) =>
    CategoriesResponse.fromJson(json.decode(str));

String categoriesToJson(CategoriesResponse data) => json.encode(data.toJson());

class CategoriesResponse {
  List<Category>? js;

  CategoriesResponse({this.js});

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) =>
      CategoriesResponse(
        js: json["js"] == null
            ? []
            : List<Category>.from(json["js"]!.map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "js": js == null ? [] : List<dynamic>.from(js!.map((x) => x.toJson())),
  };
}

class Category {
  String? id;
  String? title;

  Category({this.id, this.title});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
