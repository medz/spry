import 'dart:async';
import 'dart:typed_data';

import '../http/response.dart';
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
    _ => event.response,
  };

  if (response.headers.get('X-Powered-By') == null) {
    response.headers.set('X-Powered-By', 'spry.fun');
  }

  return response;
}

Response _fallbackResponseOf(dynamic value) {
  try {
    return Response.json(value.toJson());
  } catch (_) {
    return Response.text(value.toString());
  }
}

Response _merge(Response target, Response response) {
  final headers = target.headers;
  for (var (name, value) in response.headers) {
    headers.add(name, value);
  }
}
