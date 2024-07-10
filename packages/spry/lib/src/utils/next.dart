import '../event/event.dart';
import '../http/response.dart';
import '../locals/locals+get_or_null.dart';

/// Spry allows you to register multiple handlers using 'use',
/// and ultimately they will be executed in the order of registration.
///
/// But sometimes, we hope that the later registration will be
/// executed first, and then return to the current handler execution
/// after completion, which is the usage scenario of 'next'.
///
/// ## Example
/// ```dart
/// app.use((event) { print(1); return next(); });
///
/// app.use((event) async {
///     final response = await next(event);
///     print(2);
///     return response;
/// });
///
/// app.use((event) { print(3) });
///
/// # Results: 1,3,2
/// ```
Future<Response> next(Event event) async {
  final effect = event.locals.getOrNull<Future<Response> Function(Event)>(next);
  event.locals.remove(next);

  return switch (effect) {
    Future<Response> Function(Event) handle => handle(event),
    _ => const Response(null, status: 204),
  };
}
