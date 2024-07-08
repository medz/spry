import '../event/event.dart';
import '../http/response.dart';

abstract interface class Handler {
  Future<Response> handle(Event event);
}
