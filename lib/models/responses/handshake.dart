// To parse this JSON data, do
//
//     final handshake = handshakeFromJson(jsonString);

import 'dart:convert';

Handshake handshakeFromJson(String str) => Handshake.fromJson(json.decode(str));

String handshakeToJson(Handshake data) => json.encode(data.toJson());

class Handshake {
  Js? js;

  Handshake({this.js});

  factory Handshake.fromJson(Map<String, dynamic> json) =>
      Handshake(js: json["js"] == null ? null : Js.fromJson(json["js"]));

  Map<String, dynamic> toJson() => {"js": js?.toJson()};
}

class Js {
  String? token;

  Js({this.token});

  factory Js.fromJson(Map<String, dynamic> json) => Js(token: json["token"]);

  Map<String, dynamic> toJson() => {"token": token};
}
