import 'package:fredstalker/models/node_type.dart';

class Node {
  final String id;
  final String name;
  final NodeType type;
  const Node({required this.id, required this.name, required this.type});
  @override
  String toString() {
    return "Viewing ${type.name}: $name";
  }
}
