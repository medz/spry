import 'dart:io';

import '../../standard_web_polyfills.dart';

Headers createHeaders(HttpHeaders headers) {
  final result = Headers();
  headers.forEach((name, values) {
    for (final value in values) {
      result.append(name, value);
    }
  });

  return result;
}
