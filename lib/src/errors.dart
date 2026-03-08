import 'package:ht/ht.dart';

class HTTPError implements Exception {
  const HTTPError(this.status, {this.body, this.headers});

  final int status;
  final Object? body;
  final Headers? headers;

  Response toResponse() {
    return Response(status: status, headers: headers, body: body);
  }
}

final class NotFoundError extends HTTPError {
  const NotFoundError({required this.method, required this.path}) : super(404);

  final String method;
  final String path;
}
