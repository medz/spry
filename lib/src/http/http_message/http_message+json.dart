// ignore_for_file: file_names

import 'dart:convert';

import 'http_message.dart';
import 'http_message+text.dart';

extension HttpMessageJson on HttpMessage {
  /// Reads HTTP message body as JSON object.
  dynamic json() async {
    return switch (await text()) {
      String value => jsonDecode(value),
      _ => null,
    };
  }
}
