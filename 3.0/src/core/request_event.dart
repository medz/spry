import '../standard_web_polyfills.dart';
import 'cookies.dart';
import '_internal/provide_inject.dart';

/// Request event, receiving an HTTP request will treat it as an event, and transfer the event to the request handler for processing.
///
/// ### Example
///
/// ```dart
/// Response handler(RequestEvent event) {
///   print('Request received: ${event.url}');
///
///   return Response('Hello, world!');
/// }
/// ```
abstract interface class RequestEvent extends ProvideInject {
  /// Get or set cookies related to the current request
  Cookies get cookie;

  /// The client's IP address.
  ///
  /// **Note**: It only returns the client IP of the currently connected
  /// server, which does not mean the real user IP. If you need to handle
  /// e.g. reverse proxy, you need to use the `X-Forwarded-For` header and
  /// other headers to determine the real user IP.
  String getClientAddress();

  /// The Web API compatible request object.
  ///
  /// See also: [Request](https://developer.mozilla.org/en-US/docs/Web/API/Request)
  Request get request;

  /// Response headers Due to some restrictions imposed by Web APIs, some special request headers cannot always be set, such as `Set-Cookie`. There are also some special cases where you obtain other resources from the outside through fetch, and you need to add or overwrite response headers in other additional code. Then this helper method is very useful.
  ///
  /// ### Example
  /// ```dart
  /// Future<Response> handler(RequestEvent event) async {
  ///   event.setHeaders({'X-Test': 'Hello, world!'});
  ///
  ///   return fetch('https://example.com');
  /// }
  /// ```
  void setHeaders(Map<String, String> headers);

  /// The requested URL.
  URL get url;
}
