// ignore_for_file: file_names

import '_constants.dart';
import 'types.dart';
import 'spry+on.dart';

/// The [Spry.all] method extension.
extension SpryAll on Spry {
  /// Adds a all request method route.
  void all<T>(String path, Handler<T> handler) => on(kAllMethod, path, handler);
}
