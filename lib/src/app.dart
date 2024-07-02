import 'handler.dart';

abstract interface class App {
  void use(Handler handler);

  Handler get handler;
}
