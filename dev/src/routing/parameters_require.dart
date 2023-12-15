import 'package:routingkit/routingkit.dart';

extension ParametersRequire on Parameters {
  /// Returns named parameter value or throws [StateError] if parameter is not
  /// found.
  String require(String name) {
    final value = get(name);
    if (value == null) {
      throw StateError('Parameter "$name" is required.');
    }

    return value;
  }

  /// Returns the named parameter value as an [T] or throws [StateError] if
  /// parameter is not found.
  T requireAs<T>(String name, T Function(String) cast) {
    final value = require(name);
    return cast(value);
  }
}
