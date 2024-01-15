import 'route.dart';
import 'routes_builder.dart';

class Routes extends Iterable<Route> implements RoutesBuilder {
  Routes();

  /// Inner list of routes.
  final _inner = <Route>[];

  /// Sets or returns case sensitive mode.
  bool caseSensitive = false;

  @override
  void addRoute(Route route) => _inner.add(route);

  @override
  Iterator<Route> get iterator => _inner.iterator;
}
