import 'dart:io';

import 'spry_exception.dart';

/// Spry HTTP exception.
class SpryHttpException implements SpryException, HttpException {
  @override
  final String message;

  @override
  final StackTrace? stackTrace;

  @override
  final Uri? uri;

  /// Http status code.
  final int statusCode;

  /// Creates a new [HttpException].
  const SpryHttpException({
    required this.statusCode,
    this.message = 'Unknown Error',
    this.stackTrace,
    this.uri,
  });

  @override
  String toString() => 'HttpException: $statusCode - $message';

  /// Bad Request
  const SpryHttpException.badRequest({
    this.message = 'Bad Request',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.badRequest;

  /// Unauthorized
  const SpryHttpException.unauthorized({
    this.message = 'Unauthorized',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.unauthorized;

  /// Not Found
  const SpryHttpException.notFound({
    this.message = 'Not Found',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.notFound;

  /// Forbidden
  const SpryHttpException.forbidden({
    this.message = 'Forbidden',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.forbidden;

  /// Not Acceptable
  const SpryHttpException.notAcceptable({
    this.message = 'Not Acceptable',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.notAcceptable;

  /// Request Timeout
  const SpryHttpException.requestTimeout({
    this.message = 'Request Timeout',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.requestTimeout;

  /// Conflict
  const SpryHttpException.conflict({
    this.message = 'Conflict',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.conflict;

  /// Http Version Not Supported
  const SpryHttpException.httpVersionNotSupported({
    this.message = 'Http Version Not Supported',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.httpVersionNotSupported;

  /// Request entity too large
  const SpryHttpException.requestEntityTooLarge({
    this.message = 'Request entity too large',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.requestEntityTooLarge;

  /// Unsupported Media Type
  const SpryHttpException.unsupportedMediaType({
    this.message = 'Unsupported Media Type',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.unsupportedMediaType;

  /// Unprocessable Entity
  const SpryHttpException.unprocessableEntity({
    this.message = 'Unprocessable Entity',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.unprocessableEntity;

  /// Internal Server Error
  const SpryHttpException.internalServerError({
    this.message = 'Internal Server Error',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.internalServerError;

  /// Not Implemented
  const SpryHttpException.notImplemented({
    this.message = 'Not Implemented',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.notImplemented;

  /// Method Not Allowed
  const SpryHttpException.methodNotAllowed({
    this.message = 'Method Not Allowed',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.methodNotAllowed;

  /// Bad Gateway
  const SpryHttpException.badGateway({
    this.message = 'Bad Gateway',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.badGateway;

  /// Service Unavailable
  const SpryHttpException.serviceUnavailable({
    this.message = 'Service Unavailable',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.serviceUnavailable;

  /// Gateway Timeout
  const SpryHttpException.gatewayTimeout({
    this.message = 'Gateway Timeout',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.gatewayTimeout;

  /// Precondition Failed
  const SpryHttpException.preconditionFailed({
    this.message = 'Precondition Failed',
    this.stackTrace,
    this.uri,
  }) : statusCode = HttpStatus.preconditionFailed;
}
