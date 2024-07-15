import 'dart:convert';
import 'dart:typed_data';

import '../headers.dart';

/// HTTP message universal interface.
abstract interface class HttpMessage {
  /// Body encoding
  Encoding get encoding;

  /// Request/Response headers.
  Headers get headers;

  /// Request/Response body.
  Stream<Uint8List>? get body;
}
