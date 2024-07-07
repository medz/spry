import 'dart:async';
import 'dart:typed_data';

import '../event/event.dart';
import '../http/headers/headers.dart';
import '../http/response.dart';

abstract interface class Platform<T, R> {
  FutureOr<Uri> getRequestURI(Event event, T request);
  FutureOr<Headers> getRequestHeaders(Event event, T request);
  Stream<Uint8List>? getRequestBody(Event event, T request);
  FutureOr<R> respond(Event event, T request, Response response);
}
