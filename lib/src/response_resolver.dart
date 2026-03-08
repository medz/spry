import 'dart:typed_data';

import 'http/response.dart';
import 'event.dart';

Future<Response> resolveResponse(Event event, Object? data) async {
  return switch (data) {
    Future future => resolveResponse(event, await future),
    Response response => response,
    Stream<Uint8List> stream => Response(stream),
    Stream<List<int>> stream => Response(stream.map(Uint8List.fromList)),
    Stream<Iterable<int>> stream => Response(
      stream.map((chunk) => Uint8List.fromList(chunk.toList())),
    ),
    Uint8List bytes => Response.fromBytes(bytes),
    String value => Response.fromString(value),
    Object value => _tryCreateJsonResponse(value),
    _ => Response(null, status: 204),
  };
}

Response _tryCreateJsonResponse(Object value) {
  try {
    return Response.fromJson(value);
  } catch (_) {
    try {
      return Response.fromJson((value as dynamic).toJson());
    } catch (_) {
      rethrow;
    }
  }
}
