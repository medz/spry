import 'dart:async';

import 'package:logging/logging.dart';

/// A container for all storage related utilities.
class Storage {
  /// Internal storage map.
  final _storage = <Type, AnyStorageValue>{};

  final Logger _logger;

  Storage([Logger? logger]) : _logger = logger ?? Logger('spry.storage');

  /// Delete all values from the container. Does _not_ invoke shutdown closures.
  void clear() => _storage.clear();

  /// Test whether the given key exists in the container.
  bool contains<T>(StorageKey<T> key) => _storage.containsKey(key.runtimeType);

  /// Get the value of the given key if it exists and is of the proper type.
  T? get<T>(StorageKey<T> key) {
    return switch (_storage[key.runtimeType]?.value) {
      T value => value,
      _ => null,
    };
  }

  T set<T>(StorageKey<T> key, T value, {void Function(T value)? onShutdown}) {
    final storageValue = StorageValue(value, onShutdown: onShutdown);
    _storage[key.runtimeType] = storageValue;
    return value;
  }

  /// Remove the given key from the container.
  void remove<T>(StorageKey<T> key) =>
      _storage.remove(key.runtimeType)?.shutdown(_logger);

  /// Shutdown all values in the container.
  void shutdown() {
    for (final value in _storage.values) {
      value.shutdown(_logger);
    }
  }
}

abstract interface class AnyStorageValue<T> {
  T get value;

  void shutdown(Logger logger);
}

abstract interface class StorageKey<T> {
  const factory StorageKey() = _StorageKey<T>;
}

class _StorageKey<T> implements StorageKey<T> {
  const _StorageKey();
}

class StorageValue<T> implements AnyStorageValue<T> {
  @override
  final T value;
  final void Function(T value)? onShutdown;

  StorageValue(this.value, {this.onShutdown});

  @override
  void shutdown(Logger logger) {
    try {
      final future = Future.sync(() => onShutdown?.call(value)).then((_) {
        logger.info('Storage value shutdown complete.');
      });
      unawaited(future);
    } catch (e, stackTrace) {
      logger.warning('Could not shutdown.', e, stackTrace);
    }
  }
}
