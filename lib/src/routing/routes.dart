import 'route.dart';
import 'routes_builder.dart';

class Routes extends Iterable<Route> implements RoutesBuilder {
  Routes();

  /// Internal list of routes.
  final _routes = <Route>[];

  /// Sets or returns case sensitive mode.
  ///
  /// Default is `false`.
  bool caseSensitive = false;

  @override
  void addRoute(Route route) => _routes.add(route);

  @override
  Iterator<Route> get iterator => _routes.iterator;
}
