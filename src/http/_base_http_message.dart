import 'dart:typed_data';

/// Base HTTP message
abstract interface class BaseHttpMessage {
  /// The message body stream.
  Stream<Uint8List>? get body;

  /// Observe whether the body used.
  bool get bodyUsed;

  /// Returns the message body as bytes.
  Future<Uint8List> bytes();

  /// Returns the message body as string.
  Future<String> text();

  /// Returns the message body as decoded JSON object.
  Future json();
}
