import '../handler.dart';

/// Routes interface.
abstract interface class Routes {
  /// Adds a route.
  void addRoute(String method, String path, Handler handler);
}
