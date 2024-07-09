import 'dart:typed_data';

import '../event/event.dart';
import '../http/headers/headers.dart';
import '../http/response.dart';

abstract interface class Platform<T, R> {
  String getRequestMethod(Event event, T request);
  Uri getRequestURI(Event event, T request);
  Headers getRequestHeaders(Event event, T request);
  Stream<Uint8List>? getRequestBody(Event event, T request);

  Future<R> respond(Event event, T request, Response response);
}
