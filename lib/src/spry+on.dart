// ignore_for_file: file_names

import 'package:routingkit/routingkit.dart';

import 'types.dart';

/// The [Spry.on] extension.
extension SpryOn on Spry {
  /// Adds a handler on match [method] and [path].
  void on<T>(String method, String path, Handler<T> handler) {
    addRoute(router, method, path, handler);
  }
}
