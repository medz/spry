import 'http_message.dart';

/// HTTP request.
class Request<T> extends HttpMessage {
  /// Creates a new [Request] instance.
  Request({
    required String method,
    required this.url,
    super.headers,
    super.body,
    required this.runtime,
  }) : method = method.toUpperCase();

  /// Returns the request method.
  ///
  /// > [!NOTE]
  /// >
  /// > The method value is upper-case.
  final String method;

  /// Returns the request resolved url.
  final Uri url;

  /// Returns runtime platform native request value.
  ///
  /// - If platform is dart, the [runtime] is `HttpRequest`
  /// - If platform is Bun/Node/Deno, the [runtime] is web `Request`.
  final T runtime;
}
