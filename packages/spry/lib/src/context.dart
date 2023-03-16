import 'request.dart';
import 'response.dart';

abstract class Context {
  const Context();

  /// Get current request object.
  Request get request;

  /// The response
  Response get response;

  /// Set a value to the context.
  ///
  /// Example:
  /// ```dart
  /// context.set('bar', 'foo');
  /// context.set('foo', 123);
  /// ```
  @Deprecated('Use operator []= instead')
  void set(Object key, Object value) => this[key] = value;

  /// Get a value from the context.
  ///
  /// Example:
  /// ```dart
  /// context.get('bar'); // 'foo'
  /// ```
  @Deprecated('Use operator [] instead')
  Object? get(dynamic key) => this[key];

  /// Has a value in the context.
  bool contains(dynamic key);

  /// Set a value to the context.
  operator []=(dynamic key, Object? value);

  /// Get a value from the context.
  operator [](Object key);
}
