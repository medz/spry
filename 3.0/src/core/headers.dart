part of spry.core;

/// Spry headers
abstract class Headers implements contracts.Headers {
  /// Creates a new writable headers.
  factory Headers.writable() => _CaseInsensitiveHeaders([]);
}

/// Key insensitive headers.
class _CaseInsensitiveHeaders implements Headers {
  /// Creates a new case insensitive headers.
  const _CaseInsensitiveHeaders(this.headers);

  final List<MapEntry<String, String>> headers;

  @override
  void append(String name, String value) =>
      headers.add(MapEntry(name.toLowerCase(), value));

  @override
  void delete(String name) => headers.removeWhere(
      (element) => element.key.toLowerCase() == name.toLowerCase());

  @override
  Iterator<MapEntry<String, String>> entries() => headers.iterator;

  @override
  void forEach(void Function(String name, String value) callback) {
    for (final entry in headers) {
      callback(entry.key, entry.value);
    }
  }

  @override
  String? get(String name) {
    final values = headers
        .where((element) => element.key.toLowerCase() == name.toLowerCase())
        .map((e) => e.value);

    return values.isEmpty ? null : values.join(',');
  }

  @override
  Iterable<String> getSetCookie() {
    return headers
        .where((element) => element.key.toLowerCase() == 'set-cookie')
        .map((e) => e.value);
  }

  @override
  bool has(String name) {
    return headers
        .any((element) => element.key.toLowerCase() == name.toLowerCase());
  }

  @override
  Iterator<String> keys() => headers.map((e) => e.key).iterator;

  @override
  void set(String name, String value) {
    delete(name);
    append(name, value);
  }

  @override
  Iterator<String> values() => headers.map((e) => e.value).iterator;
}
