import 'dart:async';

import 'package:spry/spry.dart';

import 'exception_handler.dart';

/// Interceptor middleware for [Spry].
///
/// Interceptor middleware is used to intercept program exceptions and
/// errors to prevent the program from crashing.
///
/// Example:
/// ```dart
/// final Spry spry = Spry();
///
/// spry.use(Interceptor());
///
/// handler(Context context) {
///   throw Exception('This is an exception');
/// }
///
/// await spry.listen(handler, port: 3000);
/// ```
class Interceptor {
  /// The exception handler.
  final ExceptionHandler handler;

  /// Create a [Interceptor] middleware.
  ///
  /// @internal
  const Interceptor._internal(this.handler);

  /// Create a [Interceptor] middleware.
  factory Interceptor({ExceptionHandler? handler}) =>
      Interceptor._internal(handler ?? ExceptionHandler.onlyStatusCode());

  /// The interceptor middleware-style function.
  FutureOr<void> call(Context context, Next next) {
    return Future.sync(next).onError<Object>((error, stack) {
      return handler(context, error, stack);
    });
  }
}
