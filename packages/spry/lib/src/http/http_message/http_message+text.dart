// ignore_for_file: file_names

import 'dart:typed_data';

import 'http_message.dart';

extension HttpMessageText on HttpMessage {
  Future<String?> text() async {
    return switch (body) {
      Stream<Uint8List> stream => encoding.decodeStream(stream),
      _ => null,
    };
  }
}
