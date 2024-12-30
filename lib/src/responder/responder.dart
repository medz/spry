import 'dart:async';

import '../event.dart';
import '../http/response.dart';

/// Can serve as an object interface for responder.
///
/// Usually used for object self creation of responses.
abstract interface class Responder {
  /// Create the current object as a [Response].
  FutureOr<Response> respond(Event event);
}
