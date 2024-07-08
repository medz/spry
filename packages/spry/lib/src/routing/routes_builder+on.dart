import 'dart:async';

import '../event/event.dart';
import '../handler/closure_handler.dart';
import 'routes_builder.dart';

extension RoutesBuilderOn on RoutesBuilder {
  void on<T>(
      String method, String route, FutureOr<T> Function(Event event) closure) {
    addRoute(method, route, ClosureHandler(closure));
  }
}
