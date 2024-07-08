import '../event/event.dart';
import '../http/response.dart';
import '../locals/locals+get_or_null.dart';

Future<Response> next(Event event) async {
  final effect = event.locals.getOrNull<Future<Response> Function(Event)>(next);
  event.locals.remove(next);

  return switch (effect) {
    Future<Response> Function(Event) handle => handle(event),
    _ => const Response(null),
  };
}
