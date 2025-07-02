import 'package:fredstalker/models/node_type.dart';

class Node {
  final String id;
  final String name;
  final NodeType type;
  String? query;
  Node({required this.id, required this.name, required this.type, this.query});
  @override
  String toString() {
    return "Viewing ${type.name}: $name";
  }
}
