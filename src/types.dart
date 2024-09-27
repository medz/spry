import 'dart:async';
import 'dart:typed_data';

abstract interface class RequestEvent<Request> {
  Uri get url;
  void setStatus(int statusCode, [String? statusText]);
  void setHeaders(Map<String, String> headers);
  void setHeader(String name, String value);
}

typedef RequestHandler<Request, R> = FutureOr<R> Function(
    RequestEvent<Request> event);

abstract interface class Spry<Request> {
  void on<T>(String method, String path, RequestHandler<Request, T> handler);
}

extension type const Headers(Map _) implements Map {}

abstract interface class Adapter<Request> {
  Future<void> respond(
      RequestEvent<Request> event, int statusCode, Headers headers,
      [Stream<Uint8List>? body]);
}

Spry<Request> createSpry<Request>({
  required Adapter<Request> adapter,
}) {
  throw UnimplementedError();
}
