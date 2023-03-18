import 'dart:async';

import 'package:meta/meta.dart';
import 'package:spry/spry.dart';

/// Exception filter middleware for [Spry].
///
/// ## Create class-based exception filter
/// ```dart
/// class MyExceptionFilter extends ExceptionFilter<MyException> {
///   @override
///   void handler(Context context, MyException exception, StackTrace stackTrace) {
///   context.response.statusCode = 500;
///   context.response.send(exception.toString());
///  }
/// }
/// ```
/// ## Create function-based exception filter
/// ```dart
/// final ExceptionFilter<MyException> myExceptionFilter = ExceptionFilter.fromHandler((context, exception, stackTrace) {
///  context.response.statusCode = 500;
///  context.response.send(exception.toString());
/// });
/// ```
///
/// __Note:__ If you want to pass the final exception error to the
/// interceptor, you should put the filter after the interceptor, and
/// then throw the error in ExceptionFilterHandler.
abstract class ExceptionFilter<T extends Object> {
  const ExceptionFilter();

  /// The exception filter middleware-style function.
  @internal
  @mustCallSuper
  FutureOr<void> call(Context context, Next next) {
    return Future.sync(next).onError<T>(_createHandler(context));
  }

  /// Create a new [ExceptionFilter.handler] from [Context].
  FutureOr<void> Function(T, StackTrace) _createHandler(Context context) =>
      (T exception, StackTrace stack) => handler(context, exception, stack);

  /// The exception filter handler function.
  FutureOr<void> handler(Context context, T exception, StackTrace stack);

  /// Creates a new [ExceptionFilter] from a [handler] function.
  factory ExceptionFilter.fromHandler(
    FutureOr<void> Function(Context context, T exception, StackTrace stackTrace)
        handler,
  ) =>
      _InternalExceptionFilter<T>(handler);
}

class _InternalExceptionFilter<T extends Object> extends ExceptionFilter<T> {
  final FutureOr<void> Function(
      Context context, T exception, StackTrace stackTrace) fn;

  const _InternalExceptionFilter(this.fn);

  @override
  FutureOr<void> handler(Context context, T exception, StackTrace stack) =>
      fn(context, exception, stack);
}
