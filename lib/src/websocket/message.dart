import 'dart:convert';
import 'dart:typed_data';

/// WebSocket message,
class Message {
  const Message._(this.raw);

  /// Creates a [String] message.
  factory Message.text(String text) => Message._(text);

  /// Creates a [Uint8List] message.
  factory Message.bytes(Uint8List bytes) => Message._(bytes);

  /// Message raw data, Types: Uint8List or String
  final dynamic raw;

  /// Returns the message text.
  String text() {
    return switch (raw) {
      String value => value,
      _ => utf8.decode(raw),
    };
  }

  /// Returns the message bytes.
  Uint8List bytes() {
    return switch (raw) {
      Uint8List bytes => bytes,
      _ => utf8.encode(raw),
    };
  }
}
