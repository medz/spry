import 'dart:convert';
import 'dart:typed_data';

import 'headers.dart';

/// HTTP message universal interface.
abstract interface class HttpMessage {
  /// Returns the HTTP message encoding.
  Encoding get encoding;

  /// Returns the HTTP message headers.
  Headers get headers;

  /// Returns the HTTP message body stream.
  Stream<Uint8List>? get body;
}
