import 'dart:async';

import '../context.dart';
import '../middleware.dart';
import '../spry_http_exception.dart';
import 'exception_handler.dart';
import 'rethrow_exception.dart';

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
    // Reset the exception handler.
    context[ExceptionHandler] = handler;

    return Future.sync(next).onError<Object>(_createHandler(context));
  }

  /// Create a new [Interceptor] on exception handler.
  FutureOr<void> Function(Object, StackTrace) _createHandler(Context context) {
    return (Object exception, StackTrace stack) {
      if (exception is RethrowException) {
        return Future.error(exception, stack);
      }

      return resolve(context).call(context, exception, stack);
    };
  }

  /// Resolve the exception handler from [Context].
  ExceptionHandler resolve(Context context) {
    final handler = context[ExceptionHandler];
    if (handler is ExceptionHandler) {
      return handler;
    }

    return this.handler;
  }
}
