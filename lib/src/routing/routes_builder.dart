import '../handler.dart';

abstract interface class RoutesBuilder {
  void on(String method, String route, Handler handler);
}
