import 'dart:async';

import 'package:logging/logging.dart';

class Container {
  final Logger _logger;
  final _instances = <Type, _Value>{};

  Container([Logger? logger])
      : _logger = logger ?? Logger('spry.core.container');

  /// Clear all instances from the container. Does _not_ invoke shutdown.
  void clear() => _instances.clear();

  /// Test whether the given instance exists in the container.
  bool has<T>() => _instances.containsKey(_Key<T>().runtimeType);

  /// Returns the instance of the given type if it exists.
  T? get<T>() {
    return _instances[_Key<T>().runtimeType]?.value;
  }

  /// Sets the instance of the given type.
  void set<T>(T instance, {FutureOr<void> Function(T instance)? onShutdown}) {
    _instances[_Key<T>().runtimeType] =
        _Value<T>(instance, onShutdown: onShutdown);
  }

  /// Removes the instance of the given type.
  void remove<T>() => _instances.remove(_Key<T>().runtimeType);

  void shutdown() {
    for (final value in _instances.values) {
      unawaited(Future(() async {
        try {
          await value.onShutdown?.call(value.value);
          _logger.info(
            'Storage value (${value.value.runtimeType}) shutdown completed.',
          );
        } catch (error, stackTrace) {
          _logger.warning(
            'Storage value (${value.value.runtimeType}) shutdown failed.',
            error,
            stackTrace,
          );
        }
      }));
    }
  }
}

class _Key<T> {
  const _Key();
}

class _Value<T> {
  final T value;
  final FutureOr<void> Function(T value)? onShutdown;

  const _Value(this.value, {this.onShutdown});
}
