// ignore_for_file: file_names

import 'types.dart';

/// The [all] method extension.
extension RoutesAll on Routes {
  /// Adds a all request method route.
  void all<T>(String path, Handler<T> handler) => on(null, path, handler);
}
