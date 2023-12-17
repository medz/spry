import '../application.dart';
import '../core/container.dart';
import 'route.dart';
import 'routes_builder.dart';

final class Routes implements RoutesBuilder {
  /// Internal sendable box.
  final _sendableBox = _SendableBox();

  Routes();

  /// Returns all routes.
  Iterable<Route> get all => _sendableBox.routes;

  /// Resets all routes.
  set all(Iterable<Route> value) => _sendableBox.routes = value.toList();

  /// Default routing behavior of [DefaultResponder] is case-sensitive.
  ///
  /// Configure this to `true` to make it case-insensitive, default is `false`.
  bool get caseInsensitive => _sendableBox.caseInsensitive;

  /// Sets the default routing behavior of [DefaultResponder] to case-sensitive.
  /// - true: case-sensitive
  /// - false: case-insensitive
  set caseInsensitive(bool value) => _sendableBox.caseInsensitive = value;

  /// Returns the description of all routes.
  String get description => all.map((e) => e.toString()).join('\n');

  @override
  void add(Route route) => _sendableBox.routes.add(route);
}

extension ApplicationRoutes on Application {
  static const _routesKey = ContainerKey<Routes>(#spry.routing.routes);

  Routes get routes {
    final existing = container.get(_routesKey);
    if (existing != null) {
      return existing;
    }

    final routes = Routes();
    container.set(_routesKey, value: routes);

    return routes;
  }
}

class _SendableBox {
  List<Route> routes = [];
  bool caseInsensitive = false;
}
