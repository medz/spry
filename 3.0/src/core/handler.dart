import 'dart:async';

import '../standard_web_polyfills.dart';
import 'request_event.dart';

/// Spry framework request handler.
///
/// The request handler is a function that receives a [RequestEvent] object and returns a [Response] object.
///
/// ### Example
/// ```dart
/// Response handler(RequestEvent event) {
///   print('Request received: ${event.url}');
///   return Response('Hello, world!');
/// }
/// ```
typedef Handler = FutureOr<Response> Function(RequestEvent event);
