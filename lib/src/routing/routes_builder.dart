import '../handler.dart';

/// Routes builder.
abstract interface class RoutesBuilder {
  /// Adds a new route.
  void on(String method, String route, Handler handler);
}
