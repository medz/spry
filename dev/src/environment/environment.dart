import 'dart:io';

enum Environment {
  production,
  development,
  testing;

  /// Returns current platform environment.
  static Map<String, String> get process => Platform.environment;

  /// Returns a environment from the process environment.
  static String? get(String name) {
    if (bool.hasEnvironment(name)) {
      return String.fromEnvironment(name);
    }

    return process[name];
  }

  operator [](String name) => get(name);
}
