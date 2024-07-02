import 'app.dart';
import 'create_stack_handler.dart';
import 'handler.dart';

App createApp() => _AppImpl();

final class _AppImpl implements App {
  final handlerStack = <Handler>[];

  @override
  void use(Handler handler) {
    handlerStack.add(handler);
  }

  @override
  Handler get handler => createStackHandler(handlerStack.reversed);
}
