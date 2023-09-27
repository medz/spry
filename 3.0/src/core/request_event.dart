import 'cookies.dart';

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
abstract interface class RequestEvent {
  /// Cookies
  Cookies get cookie;
}
