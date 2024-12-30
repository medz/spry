import 'dart:io';

import 'http/headers.dart';

extension ToSpryHeaders on HttpHeaders {
  Headers toSpryHeaders() {
    final headers = Headers();
    forEach((name, values) {
      for (final value in values) {
        headers.add(name, value);
      }
    });

    return headers;
  }
}
