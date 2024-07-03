import 'dart:typed_data';

abstract interface class Response {
  abstract int status;
  abstract String statusText;
  List<(String, String)> get headers;
  Stream<Uint8List>? body;
}
