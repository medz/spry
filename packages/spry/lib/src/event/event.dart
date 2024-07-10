import '../http/request.dart';
import '../locals/locals.dart';

/// Request event.
abstract interface class Event {
  /// Returns current request event locals.
  Locals get locals;

  /// Return the request object for the request event.
  Request get request;
}
