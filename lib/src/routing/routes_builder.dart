import '../handler/handler.dart';

abstract interface class RoutesBuilder {
  void addRoute(String method, String route, Handler handler);
}
