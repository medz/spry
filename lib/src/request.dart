import 'dart:typed_data';

abstract interface class Request {
  String get method;
  Uri get uri;
  Iterable<(String, String)> get headers;
  Stream<Uint8List> get body;
}
