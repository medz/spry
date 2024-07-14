import 'dart:convert';
import 'dart:typed_data';

import 'headers.dart';

/// HTTP message universal interface.
abstract class HttpMessage {
  /// Request/Response headers.
  Headers get headers;

  /// Request/Response body.
  Stream<Uint8List>? get body;

  /// Returns the Request/Response body as [String].
  Future<String?> text() async {
    return switch (body) {
      Stream<Uint8List> stream => utf8.decodeStream(stream),
      _ => null,
    };
  }

  /// Returns the body as JSON.
  Future json() async {
    return switch (await text()) {
      String text => jsonDecode(text),
      _ => null,
    };
  }
}
