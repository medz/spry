// ignore_for_file: file_names

import 'http_message.dart';

extension HttpMessageText on HttpMessage {
  /// Reads the HTTP message body as text.
  Future<String?> text() async {
    return switch (body) {
      Stream<List<int>> stream => encoding.decodeStream(stream),
      _ => null,
    };
  }
}
