extension type Headers._(List<(String, String)> _)
    implements Iterable<(String, String)> {
  factory Headers([Map<String, String>? init]) {
    final inner = <(String, String)>[];
    if (init?.isNotEmpty == true) {
      inner.addAll(init!.entries.map((e) => (e.key, e.value)));
    }

    return Headers._(inner);
  }

  String? get(String name) {
    final normalizedName = _normalizeHeaderName(name);
    for (final (name, value) in _) {
      if (_normalizeHeaderName(name) == normalizedName) {
        return value;
      }
    }

    return null;
  }

  void append(String name, String value) {
    _.add((name, value));
  }

  void remove(String name) {
    _.removeWhere(createHeaderEqTest(name));
  }

  Iterable<String> valuesOf(String name) {
    return where(createHeaderEqTest(name)).map((e) => e.$2);
  }

  void set(String name, String value) {
    this
      ..remove(name)
      ..append(name, value);
  }
}

String _normalizeHeaderName(String name) => name.toLowerCase();

bool Function((String, String) _) createHeaderEqTest(String name) {
  final normalizedName = _normalizeHeaderName(name);
  return (header) => _normalizeHeaderName(header.$1) == normalizedName;
}
