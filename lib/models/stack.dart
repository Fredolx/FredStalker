import 'package:fredstalker/models/node.dart';

class Stack {
  final List<Node> _nodes = [];
  Stack();

  void add(Node node) {
    _nodes.add(node);
  }

  Node pop() {
    return _nodes.removeLast();
  }

  Node? get() {
    return _nodes.lastOrNull;
  }

  bool hasNodes() {
    return _nodes.isNotEmpty;
  }
}
