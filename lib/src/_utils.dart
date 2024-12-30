import 'dart:typed_data';

import 'package:slugid/slugid.dart';

import 'event.dart';
import 'http/formdata.dart';
import 'http/response.dart';
import 'responder/_resolve.dart';
import 'responder/responder.dart';

String createUniqueID() => Slugid.nice().toString();

Future<Response> responder(Event event, Object? data) async {
  return switch (data) {
    Future future => responder(event, await future),
    Response response => response,
    Responder(:final respond) => respond(event),
    Stream<Uint8List> stream => Response(stream),
    Stream<List<int>> stream => Response(stream.map(Uint8List.fromList)),
    Stream<Iterable<int>> stream =>
      Response(stream.map((event) => Uint8List.fromList(event.toList()))),
    Uint8List bytes => Response.fromBytes(bytes),
    String value => Response.fromString(value),
    FormData form => Response.fromFormData(form),
    TypedData data => Response.fromBytes(data.buffer.asUint8List()),
    ByteBuffer buffer => Response.fromBytes(buffer.asUint8List()),
    Object data => switch (await resove(event, data)) {
        Response response => response,
        _ => tryCreateJsonResponse(data),
      },
    _ => Response(null, status: 204),
  };
}

Response tryCreateJsonResponse(Object data) {
  try {
    return Response.fromJson(data);
  } catch (_) {
    try {
      return Response.fromJson((data as dynamic).toJson());
    } catch (_) {}

    rethrow;
  }
}
