// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:routingkit/routingkit.dart';

import '../handler/closure_handler.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilder$Closure on RoutesBuilder {
  /// Registers a route that responds to the given [method] and [path] with the
  /// result of the [closure].
  ///
  /// ```dart
  /// app.on(
  ///   (request) async => 'Hello, world!',
  ///   method: 'GET',
  ///   path: '/say-hello',
  /// );
  /// ```
  void on<T>(
    FutureOr<T> Function(HttpRequest request) closure, {
    required String method,
    required String path,
  }) {
    final route = Route<T>(
      handler: closure.makeHandler(),
      method: method,
      segments: path.asSegments,
    );

    return addRoute(route);
  }
}
