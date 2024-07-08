import 'dart:convert';
import 'dart:typed_data';

import '../headers/headers.dart';

abstract interface class HttpMessage {
  Encoding get encoding;
  Headers get headers;
  Stream<Uint8List>? get body;
}
