// ignore_for_file: file_names

import 'dart:convert';

import 'http_message.dart';
import 'http_message+text.dart';

extension HttpMessageJson on HttpMessage {
  Future json() async {
    return switch (await text()) {
      String text => jsonDecode(text),
      _ => null,
    };
  }
}
