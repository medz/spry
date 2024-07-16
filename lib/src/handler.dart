import 'event/event.dart';
import 'http/response.dart';

/// Event handler.
abstract interface class Handler {
  /// Handle the event handler.
  Future<Response> handle(Event event);
}
