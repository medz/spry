import 'dart:async';

import 'package:spry/spry.dart';
import 'package:spry_json/spry_json.dart';

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
          {Object? Function(HttpException exception)? builder}) =
      _JsonExceptionHandler;

  /// Resolve a exception to [HttpException].
  static HttpException _resolveHttpException(
      Object exception, StackTrace stackTrace) {
    if (exception is HttpException) {
      return exception;
    } else if (exception is SpryException) {
      return HttpException.internalServerError(
          exception.message.toString(), exception.stackTrace ?? stackTrace);
    } else if (exception is FormatException) {
      return HttpException.internalServerError(exception.message, stackTrace);
    } else if (exception is Exception) {
      return HttpException.internalServerError(
          exception.toString(), stackTrace);
    } else if (exception is Error) {
      return HttpException.internalServerError(
          Error.safeToString(exception), exception.stackTrace ?? stackTrace);
    }

    return HttpException.internalServerError(
        "Internal Server Error", stackTrace);
  }
}

/// Only status code no body exception handler.
class _OnlyStatusCodeExceptionHandler implements ExceptionHandler {
  const _OnlyStatusCodeExceptionHandler();

  @override
  void call(Context context, Object exception, StackTrace stackTrace) {
    final Response response = context.response;
    final HttpException httpException =
        ExceptionHandler._resolveHttpException(exception, stackTrace);

    response
      ..status(httpException.statusCode)
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
    final HttpException httpException =
        ExceptionHandler._resolveHttpException(exception, stackTrace);

    response
      ..status(httpException.statusCode)
      ..text(httpException.message);
  }
}

class _JsonExceptionHandler implements ExceptionHandler {
  final Object? Function(HttpException exception)? builder;

  const _JsonExceptionHandler({this.builder});

  static Object? _defaultJsonBuilder(HttpException exception) {
    return {
      'status': exception.statusCode,
      'message': exception.message,
    };
  }

  @override
  void call(Context context, Object exception, StackTrace stackTrace) {
    final Response response = context.response;
    final HttpException httpException =
        ExceptionHandler._resolveHttpException(exception, stackTrace);
    final builder = this.builder ?? _defaultJsonBuilder;

    response
      ..status(httpException.statusCode)
      ..json(builder(httpException));
  }
}
