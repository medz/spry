import 'dart:async';

import 'package:ht/ht.dart' show HttpMethod, Response;

import 'event.dart';

/// Handles a matched route request.
typedef Handler = FutureOr<Response> Function(Event event);

/// Route handlers keyed by HTTP method.
///
/// A `null` key matches requests for any method that does not have a more
/// specific handler.
typedef RouteHandlers = Map<HttpMethod?, Handler>;

/// Handles an error raised while processing a request.
typedef ErrorHandler =
    FutureOr<Response> Function(
      Object error,
      StackTrace stackTrace,
      Event event,
    );
