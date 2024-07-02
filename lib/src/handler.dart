import 'event.dart';

abstract interface class Handler {
  Future<void> handle(Event event);
}
