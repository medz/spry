import '_utils.dart';

/// The HTTP [Headers].
///
/// {@template spry.http.headers.example}
/// ```dart
/// final headers = Headers({'a': '1'});
///
/// print(headers.get('a')); // Prints: 1
/// ```
/// {@endtemplate}
extension type Headers._(List<(String, String)> _headers)
    implements Iterable<(String, String)> {
  /// Creates a new [Headers].
  ///
  /// - [init]: The headers init map.
  ///
  /// Example:
  /// {@macro spry.http.headers.example}
  factory Headers([Map<String, String>? init]) {
    final headers = Headers._([]);
    if (init != null && init.isNotEmpty) {
      for (final MapEntry(:key, :value) in init.entries) {
        headers.add(key, value);
      }
    }

    return headers;
  }

  /// Check if a header name exists in the [Headers].
  bool has(String name) {
    final normalizedName = normalizeHeaderName(name);
    for (final (name, _) in this) {
      if (name == normalizedName) return true;
    }
    return false;
  }

  /// Gets a first header value.
  String? get(String name) {
    final normalizedName = normalizeHeaderName(name);
    for (final (name, value) in this) {
      if (name == normalizedName) return value;
    }

    return null;
  }

  /// Gets a header all values.
  Iterable<String> getAll(String name) sync* {
    final normalizedName = normalizeHeaderName(name);
    for (final (name, value) in this) {
      if (name == normalizedName) yield value;
    }
  }

  /// Adds a new header key-value.
  void add(String name, String value) {
    _headers.add((normalizeHeaderName(name), value));
  }

  /// Sets a header, If the name exists remove it.
  void set(String name, String value) {
    final normalizedName = normalizeHeaderName(name);
    _headers
      ..removeWhere((e) => e.$1 == normalizedName)
      ..add((normalizedName, value));
  }

  /// Remove a header.
  ///
  /// If [value] is provided, delete the exact match.
  /// Otherwise, delete all values of [name].
  void remove(String name, [String? value]) {
    final normalizedName = normalizeHeaderName(name);
    bool test((String, String) e) {
      if (value != null) {
        return e.$1 == normalizedName && e.$2 == value;
      }

      return e.$1 == normalizedName;
    }

    _headers.removeWhere(test);
  }
}
