import 'package:routingkit/routingkit.dart';

extension ParametersRequire on Parameters {
  /// Grabs the named parameter from the parameter.
  String require(String name) {
    return switch (get(name)) {
      String name => name,
      _ => throw StateError('Missing parameter: $name'),
    };
  }

  /// Returns the value of the named parameter as an [T].
  T requireAs<T>(String name, T Function(String value) cast) =>
      cast(require(name));
}
