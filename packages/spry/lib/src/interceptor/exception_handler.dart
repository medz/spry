import 'dart:async';

import 'package:spry/json.dart';
import 'package:spry/spry.dart';

/// Exception handler.
abstract class ExceptionHandler {
  FutureOr<void> call(Context context, Object error, StackTrace stackTrace);

  /// Only status code no body exception handler.
  const factory ExceptionHandler.onlyStatusCode() =
      _OnlyStatusCodeExceptionHandler;

  /// Plain text exception handler.
  const factory ExceptionHandler.plainText() = _PlainTextExceptionHandler;

  /// Json exception handler.
  ///
  /// [builder] is used to build the response body.
  const factory ExceptionHandler.json(
          {Object? Function(SpryHttpException exception)? builder}) =
      _JsonExceptionHandler;

  /// Resolve a exception to [SpryHttpException].
  static SpryHttpException _resolveSpryHttpException(
      Object exception, StackTrace stackTrace) {
    if (exception is SpryHttpException) {
      return exception;
    } else if (exception is SpryException) {
      return SpryHttpException.internalServerError(
        message: exception.message.toString(),
        stackTrace: exception.stackTrace ?? stackTrace,
      );
    } else if (exception is FormatException) {
      return SpryHttpException.internalServerError(
        message: exception.message,
        stackTrace: stackTrace,
      );
    } else if (exception is Exception) {
      return SpryHttpException.internalServerError(
          message: Error.safeToString(exception), stackTrace: stackTrace);
    } else if (exception is Error) {
      return SpryHttpException.internalServerError(
        message: Error.safeToString(exception),
        stackTrace: exception.stackTrace ?? stackTrace,
      );
    }

    return SpryHttpException.internalServerError(stackTrace: stackTrace);
  }
}

/// Only status code no body exception handler.
class _OnlyStatusCodeExceptionHandler implements ExceptionHandler {
  const _OnlyStatusCodeExceptionHandler();

  @override
  void call(Context context, Object exception, StackTrace stackTrace) {
    final Response response = context.response;
    final spryHttpException =
        ExceptionHandler._resolveSpryHttpException(exception, stackTrace);

    response
      ..statusCode = spryHttpException.statusCode
      ..headers.contentLength = 0
      ..stream(Stream.empty());
  }
}

/// Plain text exception handler.
class _PlainTextExceptionHandler implements ExceptionHandler {
  const _PlainTextExceptionHandler();

  @override
  void call(Context context, Object exception, StackTrace stackTrace) {
    final Response response = context.response;
    final SpryHttpException spryHttpException =
        ExceptionHandler._resolveSpryHttpException(exception, stackTrace);

    response
      ..statusCode = spryHttpException.statusCode
      ..text(spryHttpException.message);
  }
}

class _JsonExceptionHandler implements ExceptionHandler {
  final Object? Function(SpryHttpException exception)? builder;

  const _JsonExceptionHandler({this.builder});

  static Object? _defaultJsonBuilder(SpryHttpException exception) {
    return {
      'status': exception.statusCode,
      'message': exception.message,
    };
  }

  @override
  void call(Context context, Object exception, StackTrace stackTrace) {
    final Response response = context.response;
    final SpryHttpException spryHttpException =
        ExceptionHandler._resolveSpryHttpException(exception, stackTrace);
    final builder = this.builder ?? _defaultJsonBuilder;

    response
      ..statusCode = spryHttpException.statusCode
      ..json(builder(spryHttpException));
  }
}
