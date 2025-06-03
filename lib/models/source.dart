class Source {
  int? id;
  String name;
  String url;
  String mac;
  String token;
  bool enabled;

  Source({
    this.id,
    required this.name,
    required this.url,
    required this.mac,
    required this.token,
    this.enabled = true,
  });
}
