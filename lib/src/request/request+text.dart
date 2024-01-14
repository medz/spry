// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import '../application+encoding.dart';
import 'request+application.dart';
import 'request+locals.dart';

extension Request$Text on HttpRequest {
  static const _key = #spry.request.cached.text;

  /// Returns the request body as a string.
  Future<String> text() async {
    final existing = locals[_key];
    if (existing != null) return existing;

    // Try decode the request body as a string.
    try {
      return locals[_key] = await encoding.decodeStream(this);
    } catch (_) {
      return locals[_key] = '';
    }
  }
}

extension on HttpRequest {
  Encoding get encoding {
    // Find the encoding from the content-type header.
    final contentType = headers.contentType;
    if (contentType != null) {
      final charset = contentType.parameters['charset'];
      if (charset != null) {
        return Encoding.getByName(charset) ?? application.encoding;
      }
    }

    return application.encoding;
  }
}
