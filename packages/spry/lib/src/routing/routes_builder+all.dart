// ignore_for_file: file_names

import 'dart:async';

import '../event/event.dart';
import 'routes_builder.dart';
import 'routes_builder+on.dart';

extension RoutesBuilderAll on RoutesBuilder {
  /// Spry all request method.
  static const kAllMethod = '#SPRY/__ALL__';

  /// adds a all request method route.
  void all<T>(String route, FutureOr<T> Function(Event event) closure) {
    return on(kAllMethod, route, closure);
  }
}
