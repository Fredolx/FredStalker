import 'package:fredstalker/models/node_type.dart';

class Node {
  final String id;
  final String name;
  final NodeType type;
  String? query;
  int? page;
  Node({
    required this.id,
    required this.name,
    required this.type,
    this.query,
    this.page,
  });
  @override
  String toString() {
    return "Viewing ${type.name}: $name";
  }
}
