import 'route.dart';
import 'routes_builder.dart';

class Routes implements RoutesBuilder {
  /// Internl storage
  final _Storage _storage = _Storage();

  /// Returns registed all routes
  Iterable<Route> get routes => _storage.routes;

  /// Returns case sensitive mode
  bool get caseSensitive => _storage.caseSensitive;

  /// Sets case sensitive mode
  set caseSensitive(bool value) => _storage.caseSensitive = value;

  /// The routes description
  String get description =>
      _storage.routes.map((route) => route.description).join('\n');

  @override
  void route<T>(Route<T> route) => _storage.routes.add(route);
}

class _Storage {
  final List<Route> routes = [];
  bool caseSensitive = false;
}
