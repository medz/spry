import 'dart:async';

import '../polyfills/standard_web_polyfills.dart';
import '../request/request_event.dart';
import 'responder.dart';

typedef ClosureResponder = FutureOr<Response> Function(RequestEvent event);

/// A closure-based responder.
class ClosureBasedResponder implements Responder {
  final ClosureResponder _closure;

  const ClosureBasedResponder(this._closure);

  @override
  FutureOr<Response> respond(RequestEvent event) =>
      _closure(event); // TODO: Make request error handling more robust.
}
