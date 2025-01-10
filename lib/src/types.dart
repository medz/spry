import 'dart:async';

import 'event.dart';
import 'http/response.dart';

/// Middleware next callback.
typedef Next = Future<Response> Function();

/// Spry middleware.
typedef Middleware = FutureOr<Response> Function(Event event, Next next);

/// Spry request handler.
typedef Handler<T> = FutureOr<T>? Function(Event event);
