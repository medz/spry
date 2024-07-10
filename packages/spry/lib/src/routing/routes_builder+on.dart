// ignore_for_file: file_names

import 'dart:async';

import '../event/event.dart';
import '../handler/closure_handler.dart';
import 'routes_builder.dart';

extension RoutesBuilderOn on RoutesBuilder {
  ///  Adds a closure handler.
  void on<T>(
      String method, String route, FutureOr<T> Function(Event event) closure) {
    addRoute(method, route, ClosureHandler(closure));
  }
}
