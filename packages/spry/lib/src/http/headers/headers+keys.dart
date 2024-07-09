// ignore_for_file: file_names

import 'headers.dart';

extension HeadersKeys on Headers {
  /// Returns all header keys.
  Iterable<String> get keys {
    return map((e) => e.$1).toSet();
  }
}
