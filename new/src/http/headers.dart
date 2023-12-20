import '../utilities/case_insensitive_map.dart';

/// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers)
abstract class Headers {
  final CaseInsensitiveMap<List<String>> _storage;

  /// Internal constructor, to create a new instance of `Headers`.
  const Headers._(CaseInsensitiveMap<List<String>> init) : _storage = init;

  /// Creates a new [Headers] object from a [Map].
  factory Headers([Object? init]) = _Headers;

  /// Appends a new value onto an existing header inside a Headers object, or
  /// adds the header if it does not already exist.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/append)
  void append(String name, String value) =>
      _storage[name] = [..._storage[name] ?? [], value];

  /// Deletes a header from a Headers object.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/delete)
  void delete(String name) => _storage.remove(name);

  /// Returns an iterator allowing to go through all key/value pairs contained
  /// in this object.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/entries)
  Iterable<(String, String)> entries() sync* {
    for (final MapEntry(key: key, value: value) in _storage.entries) {
      // https://fetch.spec.whatwg.org/#ref-for-forbidden-response-header-name%E2%91%A0
      if (key.toLowerCase() == 'set-cookie') continue;

      yield (key, value.join(', '));
    }
  }

  /// Executes a provided function once for each key/value pair in this Headers object.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/forEach)
  void forEach(void Function(String value, String name, Headers parent) fn) =>
      entries().forEach((element) => fn(element.$2, element.$1, this));

  /// Returns a String sequence of all the values of a header within a Headers
  /// object with a given name.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/get)
  String? get(String name) => _storage[name]?.join(', ');

  /// Returns an array containing the values of all Set-Cookie headers
  /// associated with a response.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/getSetCookie)
  Iterable<String> getSetCookie() => _storage['Set-Cookie'] ?? const <String>[];

  /// Returns a boolean stating whether a Headers object contains a certain header.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/has)
  bool has(String name) => _storage.containsKey(name);

  /// Returns an iterator allowing you to go through all keys of the key/value
  /// pairs contained in this object.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/keys)
  Iterable<String> keys() => _storage.keys;

  /// Sets a new value for an existing header inside a Headers object, or adds
  /// the header if it does not already exist.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/set)
  void set(String name, String value) => _storage[name] = [value];

  /// Returns an iterator allowing you to go through all values of the
  /// key/value pairs contained in this object.
  ///
  /// [MDN Reference](https://developer.mozilla.org/docs/Web/API/Headers/values)
  Iterable<String> values() => _storage.values.map((e) => e.join(', '));
}

final class _Headers extends Headers {
  _Headers._() : super._(CaseInsensitiveMap<List<String>>());

  /// Creates a new [Headers] object from a [Map].
  _Headers.fromMap(Map<String, String> init)
      : super._(CaseInsensitiveMap<List<String>>()) {
    init.forEach((name, value) => append(name, value));
  }

  /// Creates a new [Headers] object from a [Iterable] of key/value pairs.
  _Headers.fromIterable(Iterable<Iterable<String>> init)
      : super._(CaseInsensitiveMap<List<String>>()) {
    for (final pair in init) {
      // If the pair is empty, skip it.
      if (pair.isEmpty) continue;
      _storage[pair.first] = pair.skip(1).toList();
    }
  }

  /// Creates a new [Headers] object from a [Headers] object.
  _Headers.fromHeaders(Headers init)
      : super._(CaseInsensitiveMap<List<String>>()) {
    _storage.addAll(init._storage.copy());
  }

  /// Creates a new [Headers] object from a [Map] with all parameters.
  _Headers.fromMapWithAll(Map<String, Iterable<String>> init)
      : super._(CaseInsensitiveMap<List<String>>()) {
    _storage.addAll(init.map((key, value) => MapEntry(key, value.toList())));
  }

  /// Creates a new [Headers] object from nullable init object.
  factory _Headers([Object? init]) => switch (init) {
        final Map<String, String> init => _Headers.fromMap(init),
        final Map<String, Iterable<String>> init =>
          _Headers.fromMapWithAll(init),
        final Iterable<Iterable<String>> init => _Headers.fromIterable(init),
        _Headers(_copy: final copy) => copy(),
        final Headers init => _Headers.fromHeaders(init),
        null => _Headers._(),
        _ => throw ArgumentError.value(init, 'init', 'Invalid type'),
      };

  _Headers _copy() => _Headers.fromMapWithAll(_storage.copy());
}
