import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:spry/spry.dart';

/// Exception handler.
abstract class ExceptionHandler {
  FutureOr<void> call(Context context, Object error, StackTrace stackTrace);

  /// Only status code no body exception handler.
  factory ExceptionHandler.onlyStatusCode() =>
      const _OnlyStatusCodeExceptionHandler();

  /// Plain text exception handler.
  factory ExceptionHandler.plainText() => const _PlainTextExceptionHandler();

  /// Json exception handler.
  ///
  /// [builder] is used to build the response body.
  ///
  /// [codec] is used to encode the response body.
  ///
  /// [contentType] is used to set the response content type. Default is
  /// `application/json`.
  ///
  /// [hijackEncodeError] Hijack the encode error.
  factory ExceptionHandler.json({
    Object? Function(HttpException exception) builder =
        _JsonExceptionHandler._defaultJsonBuilder,
    Codec<Object?, String> codec = json,
    io.ContentType? contentType,
    bool hijackEncodeError = false,
  }) =>
      _JsonExceptionHandler(
        builder: builder,
        codec: codec,
        contentType: contentType ?? io.ContentType.json,
        hijackEncodeError: hijackEncodeError,
      );

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
      ..send(null);
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
      ..headers.contentType = io.ContentType.text
      ..send(httpException.message);
  }
}

class _JsonExceptionHandler implements ExceptionHandler {
  final Object? Function(HttpException exception) builder;
  final Codec<Object?, String> codec;
  final io.ContentType contentType;
  final bool hijackEncodeError;

  const _JsonExceptionHandler({
    required this.builder,
    required this.codec,
    required this.contentType,
    required this.hijackEncodeError,
  });

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
    late final String body;

    try {
      body = codec.encode(builder(httpException));
    } catch (e) {
      if (!hijackEncodeError) {
        rethrow;
      }

      body = codec.encode(_defaultJsonBuilder(httpException));
    }

    response
      ..status(httpException.statusCode)
      ..headers.contentType = contentType
      ..send(body);
  }
}
