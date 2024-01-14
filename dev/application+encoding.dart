// ignore_for_file: file_names

import 'dart:convert';

import '_internal/map+value_of.dart';
import 'application.dart';

extension Application$Encoding on Application {
  /// Returns global encoding.
  Encoding get encoding {
    return locals.valueOf(#spry.encoding, (name) {
      if (name is String?) {
        final encoding = Encoding.getByName(name);
        if (encoding != null) return encoding;
      }

      // Default encoding.
      return utf8;
    });
  }

  /// Sets global encoding.
  set encoding(Encoding encoding) => locals[#spry.encoding] = encoding;
}
