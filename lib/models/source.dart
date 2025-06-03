class Source {
  int? id;
  String name;
  String url;
  String mac;
  String? token;
  bool enabled;

  Source({
    this.id,
    required this.name,
    required this.url,
    required this.mac,
    this.enabled = true,
  });
}
