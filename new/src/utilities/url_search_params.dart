/// The [URLSearchParams] interface defines utility.
class URLSearchParams {
  final List<(String, String)> _storage;

  /// Internal constructor, to create a new instance of [URLSearchParams].
  const URLSearchParams._(List<(String, String)> init) : _storage = init;

  /// Returns a [URLSearchParams] object instance.
  ///
  /// The [URLSearchParams] constructor creates and returns a new
  /// [URLSearchParams] object.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/URLSearchParams)
  factory URLSearchParams([init]) {
    final List<(String, String)> storage = switch (init) {
      URLSearchParams(_storage: final storage) => storage,
      String init => init.toSearchParamsStorage().toList(),
      Iterable<(String, String)> init => init.toList(),
      Iterable<String> init => init.toSearchParamsStorage().toList(),
      Iterable<Iterable<String>> init => init.toSearchParamsStorage().toList(),
      Map<String, String> init =>
        init.entries.map((e) => (e.key, e.value)).toList(),
      Map<String, Iterable<String>> init =>
        init.entries.expand((e) => e.value.map((v) => (e.key, v))).toList(),
      null => [],
      _ => throw ArgumentError.value(init, 'init', 'Invalid init value'),
    };

    return URLSearchParams._(storage);
  }

  /// Indicates the total number of search parameter entries.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/size)
  int get size => _storage.length;

  /// Returns an iterator allowing iteration through all key/value pairs
  /// contained in this object in the same order as they appear in the
  /// query string.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/entries)
  Iterable<(String, String)> entries() => _storage;

  /// Allows iteration through all values contained in this object via a
  /// callback function.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/forEach)
  void forEach(
      void Function(String name, String value, URLSearchParams searchParams)
          callback) {
    for (final (name, value) in _storage) {
      callback(name, value, this);
    }
  }

  /// Returns an `Iterable` allowing iteration through all keys of the
  /// key/value pairs contained in this object.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/keys)
  Iterable<String> keys() => _storage.map((e) => e.$1);

  /// Returns an iterator allowing iteration through all values of the
  /// key/value pairs contained in this object.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/values)
  Iterable<String> values() => _storage.map((e) => e.$2);

  /// Sorts all key/value pairs, if any, by their keys.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/sort)
  void sort() => _storage.sort((a, b) => a.$1.compareTo(b.$1));

  /// Returns a boolean value indicating if a given parameter, or parameter
  ///  and value pair, exists.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/has)
  bool has(String name, [String? value]) =>
      _storage.any((e) => e.equalsIgnoreCase(name, value));

  /// Returns the first value associated with the given search parameter.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/get)
  String? get(String name) =>
      _storage.firstWhereOrNull((e) => e.equalsIgnoreCase(name))?.$2;

  /// Returns all the values associated with a given search parameter.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/getAll)
  Iterable<String> getAll(String name) =>
      _storage.where((e) => e.equalsIgnoreCase(name)).map((e) => e.$2);

  /// Appends a specified key/value pair as a new search parameter.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/append)
  void append(String name, String value) => _storage.add((name, value));

  /// Sets the value associated with a given search parameter to the given
  /// value. If there are several values, the others are deleted.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/set)
  void set(String name, String value) {
    delete(name);
    _storage.add((name, value));
  }

  /// Deletes search parameters that match a name, and optional value,
  /// from the list of all search parameters.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/delete)
  void delete(String name, [String? value]) {
    _storage.removeWhere((e) => e.equalsIgnoreCase(name, value));
  }

  /// Returns a string containing a query string suitable for use in a URL.
  ///
  /// [MDN reference](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/toString)
  @override
  String toString() {
    return _storage
        .map((e) =>
            '${e.$1.encodeQueryComponent()}=${e.$2.encodeQueryComponent()}')
        .join('&');
  }
}

extension on String {
  Iterable<(String, String)> toSearchParamsStorage() sync* {
    final params = Uri.parse(this).queryParametersAll;
    for (final MapEntry(key: name, value: values) in params.entries) {
      yield* values.map((value) => (name, value));
    }
  }

  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();

  String encodeQueryComponent() => Uri.encodeQueryComponent(this);
}

extension on (String, String) {
  bool equalsIgnoreCase(String name, [String? value]) {
    if (value == null) {
      return $1.equalsIgnoreCase(name);
    }

    return $1.equalsIgnoreCase(name) && $2 == value;
  }
}

extension on Iterable<String> {
  Iterable<(String, String)> toSearchParamsStorage() {
    return map((e) {
      final parts = e.split('=');

      if (parts.length == 1) {
        return (parts.first, '');
      }

      return (parts.first, parts.skip(1).join('='));
    });
  }
}

extension on Iterable<Iterable<String>> {
  Iterable<(String, String)> toSearchParamsStorage() {
    return expand((e) {
      if (e.isEmpty) return [];

      final name = e.first;
      final values = e.skip(1);

      return values.map((value) => (name, value));
    });
  }
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    try {
      return firstWhere(test);
    } on StateError {
      return null;
    }
  }
}
