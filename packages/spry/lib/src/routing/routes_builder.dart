import 'route.dart';

abstract interface class RoutesBuilder {
  /// Adds a route to the routes.
  void addRoute<T>(Route<T> route);
}
