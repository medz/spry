import 'http_message.dart';

class Request extends HttpMessage {
  Request({
    required this.method,
    required this.url,
    super.headers,
    super.body,
  });

  final String method;
  final Uri url;
}
