import '../handler.dart';

abstract interface class Router implements Handler {
  void use(Handler handler);
}
