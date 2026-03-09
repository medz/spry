import 'package:ht/ht.dart';

/// Base HTTP exception used to convert failures into responses.
class HTTPError implements Exception {
  /// Creates an HTTP error with a status, optional body, and headers.
  const HTTPError(this.status, {this.body, this.headers});

  /// HTTP status code.
  final int status;

  /// Optional response body.
  final Object? body;

  /// Optional response headers.
  final Headers? headers;

  /// Converts the error to an HTTP response.
  Response toResponse() {
    return Response(status: status, headers: headers, body: body);
  }
}

/// Error thrown when no route or fallback matches a request.
final class NotFoundError extends HTTPError {
  /// Creates a 404 error for an unmatched request.
  const NotFoundError({required this.method, required this.path}) : super(404);

  /// Request method.
  final String method;

  /// Request path.
  final String path;
}
