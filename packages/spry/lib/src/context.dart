import 'request.dart';
import 'response.dart';

abstract class Context {
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
  void set(Object key, Object value);

  /// Get a value from the context.
  ///
  /// Example:
  /// ```dart
  /// context.get('bar'); // 'foo'
  /// ```
  Object? get(Object key);
}
