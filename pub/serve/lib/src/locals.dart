/// A class for storing and retrieving local values associated with a server request.
class ServerLocals {
  final _store = {};

  /// Checks if a local value exists with the given [name].
  bool has(Object name) => _store.containsKey(name);

  /// Retrieves a local value of type [T] associated with the given [name].
  /// Throws an [Exception] if no value exists for [name].
  T get<T>(Object name) {
    if (has(name)) return _store[name];
    throw Exception('No such local: $name');
  }

  /// Sets a local value of type [T] associated with the given [name].
  /// Returns the set value.
  T set<T>(Object name, T value) => _store[name] = value;
}
