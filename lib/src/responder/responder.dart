import 'dart:async';

import 'package:webfetch/webfetch.dart';

import '../request/request_event.dart';

/// Spry responder.
///
/// The responder is responsible for responding to requests.
abstract interface class Responder {
  /// Responds to the given [event].
  FutureOr<Response> respond(RequestEvent event);
}
