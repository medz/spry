/// Spry exception filter library.
library spry.exception_filter;

import 'dart:async';

import 'spry.dart';

/// Exception source, used for packaging [Exception] and [Error], as well as [StackTrace].
class ExceptionSource<T> {
  const ExceptionSource(this.exception, this.stackTrace);

  /// Returns the [Exception] or [Error].
  final T exception;

  /// Returns current error [StackTrace].
  final StackTrace stackTrace;
}

/// Exception filter interface.
///
/// The use of interfaces is to create filters in a more standardized manner.
///
/// ## Example
/// ```dart
/// class MyException {}
///
/// class MyExceptionFilter implements ExceptionFilter<MyException> {
///     Future<Response> process(Event event, ExceptionSource<MyException> source) {
///         return Response.text('My exception');
///     }
/// }
///
/// app.use(withExceptionFilter(MyExceptionFilter()));
/// ```
abstract interface class ExceptionFilter<T> {
  /// Handling exceptions.
  ///
  /// If you don't want to handle the current exception, you can directly
  /// return null, which can transfer the exception to the upper level registered
  /// filter for processing.
  Future<Response?> process(Event event, ExceptionSource<T> source);
}

/// Define exception filter.
///
/// Many times, using [ExceptionFilter] to create filters can be cumbersome,
/// especially when we have a simple exception that requires friendly handling.
/// Using [defineExceptionFilter] is an easier option.
///
/// ```dart
/// app.use(defineExceptionFilter<Error>((event, source) {
///     return Response.json(status: 412, {
///         "message": Error.safeToString(source.exception),
///         "code": -1,
///     });
/// }));
/// ```
Future<Response> Function(Event event) defineExceptionFilter<T>(
    FutureOr<Response?> Function(Event event, ExceptionSource<T> source)
        process) {
  return (Event event) async {
    try {
      return await next(event);
    } catch (exception, stackTrace) {
      if (exception is T) {
        final response =
            await process(event, ExceptionSource(exception as T, stackTrace));
        if (response != null) {
          return response;
        }
      } else if (exception is Response) {
        return exception;
      }

      rethrow;
    }
  };
}

/// Convert [ExceptionFilter] to handle.
///
/// [withExceptionFilter] can register filters to Spry with semantic meaning.
///
/// ```dart
/// app.use(withExceptionFilter(...));
/// ```
Future<Response> Function(Event event) withExceptionFilter<T>(
    ExceptionFilter<T> filter) {
  return defineExceptionFilter(filter.process);
}
