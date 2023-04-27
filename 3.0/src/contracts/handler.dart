import 'dart:async';

import 'request.dart';

/// Spry handler contract.
abstract class Handler {
  /// Handles the given [request].
  FutureOr<void> handle(Request request, Response response);
}
