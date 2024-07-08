// ignore_for_file: file_names

import 'headers.dart';

extension HeadersHas on Headers {
  bool has(String name) {
    final normalizedName = name.toLowerCase();
    return any((e) => e.$1.toLowerCase() == normalizedName);
  }
}
