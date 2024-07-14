import '../core/handler.dart';

/// Routes builder.
abstract interface class RoutesBuilder {
  /// Adds a new route.
  void addRoute(String method, String route, Handler handler);
}
