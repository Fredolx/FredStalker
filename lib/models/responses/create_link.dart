// To parse this JSON data, do
//
//     final createLink = createLinkFromJson(jsonString);

import 'dart:convert';

CreateLink createLinkFromJson(String str) =>
    CreateLink.fromJson(json.decode(str));

String createLinkToJson(CreateLink data) => json.encode(data.toJson());

class CreateLink {
  Js? js;
  int? streamerId;
  int? linkId;
  int? load;
  String? error;

  CreateLink({this.js, this.streamerId, this.linkId, this.load, this.error});

  factory CreateLink.fromJson(Map<String, dynamic> json) => CreateLink(
    js: json["js"] == null ? null : Js.fromJson(json["js"]),
    streamerId: json["streamer_id"],
    linkId: json["link_id"],
    load: json["load"],
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "js": js?.toJson(),
    "streamer_id": streamerId,
    "link_id": linkId,
    "load": load,
    "error": error,
  };
}

class Js {
  String? id;
  String? cmd;

  Js({this.id, this.cmd});

  factory Js.fromJson(Map<String, dynamic> json) =>
      Js(id: json["id"], cmd: json["cmd"]);

  Map<String, dynamic> toJson() => {"id": id, "cmd": cmd};
}
