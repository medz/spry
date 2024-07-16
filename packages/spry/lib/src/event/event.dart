import '../http/request.dart';

/// Request event.
abstract interface class Event {
  /// Return the request object for the request event.
  Request get request;
}
