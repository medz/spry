import 'package:routingkit/routingkit.dart';
import 'package:spry/src/handler.dart';

import '../application.dart';

Application createApp() => _AppImpl();

final class _AppImpl implements Application {
  @override
  void on(String method, String route, Handler handler) {
    addRoute(router, method, route, handler);
  }

  @override
  late final router = createRouter<Handler>();
}
