// ignore_for_file: file_names

import '../handler.dart';
import '../utils/define_stack_handler.dart';
import 'routes_builder.dart';

extension RoutesBuilderGroup on RoutesBuilder {
  RoutesBuilder grouped({String? route, Handler? handler}) {
    return _GroupedRoutesBuilder(
      parent: this,
      route: route,
      handler: handler,
    );
  }

  void group(void Function(RoutesBuilder routes) closure,
      {String? route, Handler? handler}) {
    return closure(grouped(route: route, handler: handler));
  }
}

class _GroupedRoutesBuilder implements RoutesBuilder {
  const _GroupedRoutesBuilder({
    required this.parent,
    required this.route,
    required this.handler,
  });

  final RoutesBuilder parent;
  final String? route;
  final Handler? handler;

  @override
  void on(String method, String route, Handler handler) {
    parent.on(method, resolveRoute(route), resolveHandler(handler));
  }

  String resolveRoute(String route) {
    return switch (this.route) {
      String prefix => '$prefix/$route',
      _ => route,
    };
  }

  Handler resolveHandler(Handler handler) {
    return switch (this.handler) {
      Handler parent => defineStackHandler([parent, handler]),
      _ => handler,
    };
  }
}
