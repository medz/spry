import 'context.dart';
import 'handler.dart';

abstract interface class App {
  void use(Handler handler);
  Context get context;
  Handler get handler;
}
