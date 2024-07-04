import 'dart:convert';
import 'dart:typed_data';

import '../event.dart';

/// Returns request body stream.
Stream<Uint8List> getBodyStream(Event event) {
  return event.raw.request.body;
}

/// Returns request raw body.
Future<Uint8List> getRawBody(Event event) async {
  final raw = <int>[];
  await for (final chunk in getBodyStream(event)) {
    raw.addAll(chunk);
  }

  return Uint8List.fromList(raw);
}

/// Returns the request text body.
Future<String> getTextBody(Event event) {
  return utf8.decodeStream(getBodyStream(event));
}

/// Returns the request JSON body
Future<dynamic> getJSONBody(Event event) async {
  final text = await getTextBody(event);
}
