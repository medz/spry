/// HTTP headers
extension type Headers._(List<(String, String)> _)
    implements Iterable<(String, String)> {
  /// Creates a new headers.
  factory Headers([Map<String, String>? init]) {
    final inner = <(String, String)>[];
    if (init?.isNotEmpty == true) {
      inner.addAll(init!.entries.map((e) => (e.key, e.value)));
    }

    return Headers._(inner);
  }

  /// Gets a header value for [name].
  String? get(String name) {
    final normalizedName = _normalizeHeaderName(name);
    for (final (name, value) in _) {
      if (_normalizeHeaderName(name) == normalizedName) {
        return value;
      }
    }

    return null;
  }

  /// Gets a header values for [name].
  Iterable<String> getAll(String name) {
    return where(_createHeaderEqTest(name)).map((e) => e.$2);
  }

  /// Add/appent a new header.
  void add(String name, String value) {
    _.add((name, value));
  }

  /// Set/Reset a header.
  void set(String name, String value) {
    this
      ..remove(name)
      ..add(name, value);
  }

  /// Remove a header.
  void remove(String name) {
    _.removeWhere(_createHeaderEqTest(name));
  }
}

String _normalizeHeaderName(String name) => name.toLowerCase();

bool Function((String, String) _) _createHeaderEqTest(String name) {
  final normalizedName = _normalizeHeaderName(name);
  return (header) => _normalizeHeaderName(header.$1) == normalizedName;
}
