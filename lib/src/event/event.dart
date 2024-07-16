import '../http/request.dart';
import '../spry.dart';

/// Request event.
abstract interface class Event {
  /// Returns current Spry application instance.
  Spry get app;

  /// Event locals.
  Map get locals;

  /// The event request.
  Request get request;
}
