import '../handler/handler.dart';

/// Spry routes builder.
abstract interface class RoutesBuilder {
  /// Adds a route for [method]/[route]/[handler].
  void addRoute(String method, String route, Handler handler);
}
