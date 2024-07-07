import '../event/event+set_headers.dart';
import '../event/event.dart';
import '../http/headers/headers_builder.dart';
import '../http/headers/headers_builder+set.dart';
import '../http/response.dart';
import '../locals/locals+get_or_null.dart';

Future<Response> next(Event event) async {
  final headers = event.locals
      .getOrNull<Map<String, String>>(EventSetHeaders.kResponsibleHeaders);
  final effect = event.locals.getOrNull<Future<Response> Function(Event)>(next);
  event.locals.remove(next);

  return switch (effect) {
    Future<Response> Function(Event) next => next(event),
    _ => _createDefaultResponse(headers),
  };
}

Response _createDefaultResponse(Map<String, String>? headers) {
  if (headers == null || headers.isEmpty) {
    return const Response(null);
  }

  final builder = HeadersBuilder();
  for (final header in headers.entries) {
    builder.set(header.key, header.value);
  }

  return Response(null, headers: builder.toHeaders());
}
