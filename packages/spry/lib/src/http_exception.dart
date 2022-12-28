import 'dart:io';

import 'spry_exception.dart';

/// Spry HTTP exception.
class HttpException implements SpryException {
  @override
  final String message;

  @override
  final StackTrace? stackTrace;

  /// Http status code.
  final int statusCode;

  /// Creates a new [HttpException].
  const HttpException(this.statusCode, this.message, [this.stackTrace]);

  @override
  String toString() => 'HttpException: $statusCode - $message';

  /// Bad Request
  factory HttpException.badRequest(
          [String message = 'Bad Request', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.accepted, message, stackTrace);

  /// Unauthorized
  factory HttpException.unauthorized(
          [String message = 'Unauthorized', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.unauthorized, message, stackTrace);

  /// Not Found
  factory HttpException.notFound(
          [String message = 'Not Found', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.notFound, message, stackTrace);

  /// Forbidden
  factory HttpException.forbidden(
          [String message = 'Forbidden', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.forbidden, message, stackTrace);

  /// Not Acceptable
  factory HttpException.notAcceptable(
          [String message = 'Not Acceptable', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.notAcceptable, message, stackTrace);

  /// Request Timeout
  factory HttpException.requestTimeout(
          [String message = 'Request Timeout', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.requestTimeout, message, stackTrace);

  /// Conflict
  factory HttpException.conflict(
          [String message = 'Conflict', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.conflict, message, stackTrace);

  /// Http Version Not Supported
  factory HttpException.httpVersionNotSupported(
          [String message = 'Http Version Not Supported',
          StackTrace? stackTrace]) =>
      HttpException(HttpStatus.httpVersionNotSupported, message, stackTrace);

  /// Payload Too Large
  factory HttpException.payloadTooLarge(
          [String message = 'Payload Too Large', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.requestEntityTooLarge, message, stackTrace);

  /// Unsupported Media Type
  factory HttpException.unsupportedMediaType(
          [String message = 'Unsupported Media Type',
          StackTrace? stackTrace]) =>
      HttpException(HttpStatus.unsupportedMediaType, message, stackTrace);

  /// Unprocessable Entity
  factory HttpException.unprocessableEntity(
          [String message = 'Unprocessable Entity', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.unprocessableEntity, message, stackTrace);

  /// Internal Server Error
  factory HttpException.internalServerError(
          [String message = 'Internal Server Error', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.internalServerError, message, stackTrace);

  /// Not Implemented
  factory HttpException.notImplemented(
          [String message = 'Not Implemented', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.notImplemented, message, stackTrace);

  /// Im a teapot
  factory HttpException.imATeapot(
          [String message = 'Im a teapot', StackTrace? stackTrace]) =>
      HttpException(418, message, stackTrace);

  /// Method Not Allowed
  factory HttpException.methodNotAllowed(
          [String message = 'Method Not Allowed', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.methodNotAllowed, message, stackTrace);

  /// Bad Gateway
  factory HttpException.badGateway(
          [String message = 'Bad Gateway', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.badGateway, message, stackTrace);

  /// Service Unavailable
  factory HttpException.serviceUnavailable(
          [String message = 'Service Unavailable', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.serviceUnavailable, message, stackTrace);

  /// Gateway Timeout
  factory HttpException.gatewayTimeout(
          [String message = 'Gateway Timeout', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.gatewayTimeout, message, stackTrace);

  /// Precondition Failed
  factory HttpException.preconditionFailed(
          [String message = 'Precondition Failed', StackTrace? stackTrace]) =>
      HttpException(HttpStatus.preconditionFailed, message, stackTrace);
}
