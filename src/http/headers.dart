const _singleValueNames = [
  /// General
  'cache-control',
  'connection',
  'date',
  'expect',
  'pragma',
  'trailer',
  'transfer-encoding',
  'upgrade',
  'via',
  'warning',

  /// Response
  'accept-ranges',
  'age',
  'content-length',
  'content-md5',
  'content-type',
  'etag',
  'last-modified',
  'location',
  'server',
  'vary',
  'www-authenticate'
];

/// Spry headers.
extension type const Headers._(List<(String, String)> _)
    implements Iterable<(String, String)> {
  /// Creates a new Spry headers instance.
  factory Headers([Map<String, String>? init]) {
    final inner = <(String, String)>[];
    if (init != null && init.isNotEmpty) {
      for (final MapEntry(:key, :value) in init.entries) {
        inner.add((key, value));
      }
    }

    return Headers._(inner);
  }

  /// Delete a header values for [name].
  void delete(String name) => _.removeWhere(_createIgnoreCaseTester(name));

  /// Appends a new header KV part into headers.
  void append(String name, String value) {
    final lowerCase = name.toLowerCase();

    // If the header name is single value defined, remove prev values.
    if (_singleValueNames.contains(lowerCase)) {
      delete(name);
    }

    _.add((name, value));
  }

  /// Returns a header value of [name].
  ///
  /// If the header value is multi-values, Using the `, ` joined
  /// and returns it.
  ///
  /// If not set the header, return `null` value.
  ///
  /// **Note**: The method not support returns `set-cookoe` name, if
  /// you need get `set-cookie` values, please using [getSetCookie] method.
  String get(String name) {
    return where(_createIgnoreCaseTesterWithoutSetCookie(name))
        .map((e) => e.$2)
        .join(', ');
  }

  /// Returns the `set-cookie` name header values.
  Iterable<String> getSetCookie() {
    return where(_createIgnoreCaseTester('set-cookie')).map((e) => e.$2);
  }

  /// Observe whether the header [name] exists.
  bool has(String name) {
    return any(_createIgnoreCaseTester(name));
  }

  /// Sets a header value for [name].
  void set(String name, String value) {
    delete(name);
    append(name, value);
  }

  /// Returns the headers all name keys.
  Iterable<String> keys() {
    return map((e) => _normalizeHeaderName(e.$1)).toSet();
  }

  /// Returns the headers all values.
  Iterable<String> values() sync* {
    for (final name in keys()) {
      if (name.toLowerCase() == 'set-cookie') {
        continue;
      }

      yield get(name);
    }

    yield* getSetCookie();
  }
}

String _normalizeHeaderName(String name) => name.toLowerCase();

bool Function((String, String)) _createIgnoreCaseTester(String name) {
  final normalized = _normalizeHeaderName(name);
  return (e) => _normalizeHeaderName(e.$1) == normalized;
}

bool Function((String, String)) _createIgnoreCaseTesterWithoutSetCookie(
    String name) {
  final test = _createIgnoreCaseTester(name);
  return (e) => switch (e.$1.toLowerCase()) {
        'set-cookie' => false,
        _ => test(e),
      };
}
