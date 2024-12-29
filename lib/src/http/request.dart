import 'http_message.dart';

class Request<T> extends HttpMessage {
  Request({
    required String method,
    required this.url,
    super.headers,
    super.body,
    required this.runtime,
  }) : method = method.toUpperCase();

  final String method;
  final Uri url;
  final T runtime;
}
