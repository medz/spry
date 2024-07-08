// ignore_for_file: file_names

import 'headers.dart';

extension HeadersGet on Headers {
  Iterable<String> getAll(String name) {
    final normalizedName = name.toLowerCase();
    return where((e) => e.$1.toLowerCase() == normalizedName).map((e) => e.$2);
  }

  String? get(String name) {
    return switch (getAll(name)) {
      Iterable(isNotEmpty: true, join: final join) => join(', '),
      _ => null,
    };
  }
}
