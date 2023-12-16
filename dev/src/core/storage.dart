import 'package:logging/logging.dart';

abstract class Storage {
  final Logger logger;

  Storage(this.logger);

  /// Internal storage.
  final Map<dynamic, AnyStorageValue> _storage = {};

  /// Clears the storage.
  void clear() => _storage.clear();

  /// Returns whether the storage contains the given key.
  bool constains<T>(StorageKey<T> key) => _storage.containsKey(key.name);

  /// Returns the value associated with the given key.
  T? get<T>(StorageKey<T> key) {
    return switch (_storage[key.name]) {
      StorageValue<T>(value: final value) => value,
      _ => null,
    };
  }

  /// Sets the value associated with the given key.
  void set<T>(
    StorageKey<T> key, {
    T? value,
    void Function(T)? onShutdown,
  }) {
    if (value != null) {
      _storage[key.name] = StorageValue<T>(value, onShutdown: onShutdown);

      return;
    }

    _storage.remove(key.name)?.shutdown(logger);
  }

  /// For every value in the storage, calls its shutdown function.
  void shutdown() {
    for (final value in _storage.values) {
      value.shutdown(logger);
    }
  }
}

abstract interface class AnyStorageValue {
  void shutdown(Logger logger);
}

class StorageKey<T> {
  final dynamic name;

  const StorageKey(this.name);
}

class StorageValue<T> implements AnyStorageValue {
  final T value;
  final void Function(T)? _onShutdown;

  const StorageValue(this.value, {void Function(T)? onShutdown})
      : _onShutdown = onShutdown;

  @override
  void shutdown(Logger logger) {
    try {
      _onShutdown?.call(value);
    } catch (e) {
      logger.warning('Could not shutdown $T: $e');
    }
  }
}
