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
