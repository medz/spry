import 'package:routingkit/routingkit.dart';

import '../http/responder.dart';

class Route {
  final String method;
  final Iterable<PathComponent> path;
  final Responder responder;
  final String? _description;

  Route({
    required this.method,
    required this.path,
    required this.responder,
    String? description,
  }) : _description = description;

  String? get description => _description;

  @override
  String toString() => description ?? '$method $path';
}
