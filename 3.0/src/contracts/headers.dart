/// Spry headers
///
/// @see https://developer.mozilla.org/zh-CN/docs/Web/API/Headers
abstract class Headers {
  /// Appends a new value onto an existing header inside a [Headers] object,
  /// or adds the header if it does not already exist.
  void append(String name, String value);

  /// Deletes a header from the current [Headers] object.
  void delete(String name);

  /// Returns an [Iterable] of all key, value pairs of all headers.
  Iterator<MapEntry<String, String>> entries();

  /// Executes a provided function once for each key/value pair in this
  /// [Headers] object.
  void forEach(void Function(String name, String value) callback);

  /// Returns a [String] sequence of all the values of a header within a
  /// [Headers] object with a given name.
  String? get(String name);

  /// Returns an [Iterable] containing the values of all `set-cookie` headers
  /// associated with a [Headers] object.
  Iterable<String> getSetCookie();

  /// Returns a boolean stating whether a [Headers] object contains a
  /// certain header.
  bool has(String name);

  /// Returns an [Iterator] of keys in the [Headers] object.
  Iterator<String> keys();

  /// Sets a new value for an existing header inside a [Headers] object, or adds
  /// the header if it does not already exist.
  void set(String name, String value);

  /// Returns an [Iterator] allowing iteration through all values of the
  /// [Headers] object.
  Iterator<String> values();
}
