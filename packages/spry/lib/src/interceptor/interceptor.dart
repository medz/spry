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
  const Interceptor({
    this.handler = const ExceptionHandler.plainText(),
  });

  /// Create a only status code no body exception handler interceptor.
  const Interceptor.onlyStatusCode()
      : handler = const ExceptionHandler.onlyStatusCode();

  /// Create a plain text exception handler interceptor.
  const Interceptor.plainText() : handler = const ExceptionHandler.plainText();

  /// Create a json exception handler interceptor.
  Interceptor.json({Object? Function(SpryHttpException exception)? builder})
      : handler = ExceptionHandler.json(builder: builder);

  /// The interceptor middleware-style function.
  FutureOr<void> call(Context context, Next next) {
    return Future.sync(next).onError<Object>((error, stack) {
      return handler(context, error, stack);
    });
  }
}
