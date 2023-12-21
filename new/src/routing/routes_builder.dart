import 'route.dart';

abstract interface class RoutesBuilder {
  /// Adds a route to the routers.
  void route<T>(Route<T> route);
}
