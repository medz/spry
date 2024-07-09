import '../event/event.dart';
import '../http/response.dart';

/// Spry application handler interface.
abstract interface class Handler {
  /// Handle a request [Event] and returns the [Response].
  Future<Response> handle(Event event);
}
