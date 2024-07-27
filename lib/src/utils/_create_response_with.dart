import 'dart:async';
import 'dart:typed_data';

import '../http/response.dart';
import '../next.dart';
import '../types.dart';

Future<Response> createResponseWith(Event event, FutureOr value) async {
  final response = switch (await value) {
    Response response => response,
    Stream<Uint8List> stream => Response(stream),
    Stream<List<int>> stream => Response(stream.map(Uint8List.fromList)),
    Map json => Response.json(json),
    List json => Response.json(json),
    Iterable json => Response.json(json.toList()),
    String text => Response.text(text),
    Object value => _fallbackResponseOf(value),
    _ => await next(event),
  };

  return response..headers.set('X-Powered-By', 'spry.fun');
}

Response _fallbackResponseOf(dynamic value) {
  try {
    return Response.json(value.toJson());
  } catch (_) {
    return Response.text(value.toString());
  }
}
