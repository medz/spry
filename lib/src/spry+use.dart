// ignore_for_file: file_names

import 'types.dart';

/// The [Spry.use] extension.
extension SpryUse on Spry {
  /// Adds a [Handler] into [Spry.stack].
  void use<T>(Handler<T> handler) {
    stack.add(handler);
  }
}
