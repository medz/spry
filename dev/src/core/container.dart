import 'package:logging/logging.dart';

class Container {
  late final Logger _logger;
  final Map<Symbol, ContainerValue> _values = {};

  Container({Logger? logger}) {
    _logger = logger ?? Logger('spry.container');
  }

  /// Delete all values from the container. Does _not_ invoke shutdown closures.
  void clear() => _values.clear();

  /// Test whether the given key exists in the container.
  bool contains<T>(ContainerKey<T> key) => _values.containsKey(key.symbol);

  /// Get the value of the given key if it exists and is of the proper type.
  T? get<T>(ContainerKey<T> key) {
    return switch (_values[key.symbol]) {
      ContainerValue(value: final value) => value,
      _ => null,
    };
  }

  /// Set or remove a value for a given key, optionally providing a shutdown
  /// closure for the value.
  ///
  /// If [value] is `null`, the value for the given key will be removed from
  /// the container.
  void set<T>(ContainerKey<T> key, {T? value, void Function(T)? onShutdown}) {
    if (value != null) {
      _values[key.symbol] = _Value<T>(value, onShutdown: onShutdown);
      return;
    }

    _values.remove(key.hashCode)?.shutdown(_logger);
  }

  /// For every key in the container having a shutdown closure, invoke the
  /// closure. Designed to be called when the container is no longer needed.
  void shutdown() {
    for (final value in _values.values) {
      value.shutdown(_logger);
    }
  }
}

class ContainerKey<T> {
  final Symbol symbol;

  const ContainerKey(this.symbol);
}

abstract interface class ContainerValue<T> {
  T get value;

  void shutdown(Logger logger);
}

class _Value<T> implements ContainerValue {
  @override
  final T value;

  final void Function(T)? onShutdown;

  _Value(this.value, {this.onShutdown});

  @override
  void shutdown(Logger logger) {
    try {
      onShutdown?.call(value);
    } catch (e, stackTrace) {
      logger.warning('Failed to shutdown value', e, stackTrace);
    }
  }
}
