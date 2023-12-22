import 'dart:developer';
import 'dart:io';

import 'package:consolekit/consolekit.dart';
import 'package:dotenv/dotenv.dart';
import 'package:path/path.dart';

final _dotenv = DotEnv(includePlatformEnvironment: false);
Iterable<String> _arguments = Platform.executableArguments;
String _executable = _currentExecutable;

/// Spry environment.
///
/// The environment the application is running in, i.e., development, testing,
/// or production.
///
/// ```dart
/// import 'package:spry/spry.dart';
///
/// void main(List<String> args) {
///   final env = Environment.development;
///   print(env.get('SPRY_ENV')); // development
/// }
/// ```
enum Environment {
  production,
  testing,
  development,

  //-------------------------- Beautiful -----------------------------//
  /******************************/; //**********************************/
  //------------------------------------------------------------------//

  //-------------------------- Static Helper -------------------------//
  /// Static helper, Reads a defined environment variable.
  static String? get(String name) {
    // If using `dart --define=K=V` or `dart -D K=V`, then the value of `K` is
    // returned.
    if (bool.hasEnvironment(name)) {
      return String.fromEnvironment(name);
    }

    return _dotenv[name] ?? Platform.environment[name];
  }

  /// Sets a defined environment variable.
  static void set(String name, String value) => _dotenv.addAll({name: value});

  /// Reads a file's content for a secret. The secret key is the name of the
  /// environment variable that is expected to specify the path of the file
  /// containing the secret.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final jwtSecret = Environment.secret('JWT_SECRET');
  /// ```
  ///
  /// **NOTE**: If the environment variable is not defined, or the file does not
  /// exist, then `null` is returned.
  static String? secret(String name) {
    return switch (get(name)?.trim()) {
      String(file: final File file) => file.readAsStringSync(),
      _ => null,
    };
  }
  //-------------------------------------------------------------------//

  //-------------------------- Detect Environment ---------------------//
  /// Detects the environment from the command-line arguments.
  ///
  /// If the `--env` option is used, then the value of the option is used as the
  /// environment. Otherwise, the value of the `SPRY_ENV` environment variable
  /// is used. If neither are set, then the environment defaults to
  /// `development`.
  ///
  /// ```dart
  /// void main(List<String> arguments) {
  ///   final env = Environment.detect(arguments: arguments);
  ///
  ///   print(env.get('SPRY_ENV')); // development
  /// }
  /// ```
  ///
  /// Using in Spry application:
  ///
  /// ```dart
  /// void main(List<String> arguments) {
  ///  final environment = Environment.detect(arguments: arguments);
  ///  final app = Spry(environment: environment);
  ///
  ///  if (environment == Environment.development) {
  ///     app.middleware.use(DebugMiddleware());
  ///  }
  /// }
  /// ```
  static Environment detect({
    Iterable<String>? arguments,
    String? executable,
  }) {
    _dotenv.tryLoadFiles(['.env']);

    arguments = switch (arguments) {
      Iterable<String> arguments when arguments.isNotEmpty => arguments,
      _ => _arguments,
    };
    executable = switch (executable) {
      String executable when executable.isNotEmpty => executable,
      _ => _executable,
    };

    final input = CommandInput(executable, List.from(arguments));
    final option = CommandOption(
      'env',
      optional: true,
      defaultsTo: Environment.development.name,
      description: 'The environment to run the Spry application in, i.e., '
          'development, testing, or production. Defaults to "development". '
          'If you customize the value is a dot env file, e.g., '
          '`dart run main.dart --env .env',
    );

    _arguments = arguments;
    _executable = executable;

    return option.parse(input);
  }

  /// Returns current environment arguments.
  static Iterable<String> get arguments => _arguments;

  /// Sets current environment arguments.
  static set arguments(Iterable<String> arguments) {
    _arguments = arguments;
  }

  /// Returns current environment executable.
  static String get executable => _executable;

  /// Sets current environment executable.
  static set executable(String executable) {
    _executable = executable;
  }
}

extension EnvironmentProperties on Environment {
  /// Returns current environment arguments.
  ///
  /// @see [Environment.arguments]
  Iterable<String> get arguments => Environment.arguments;

  /// Sets current environment arguments.
  ///
  /// @see [Environment.arguments]
  set arguments(Iterable<String> arguments) =>
      Environment.arguments = arguments;

  /// Returns current environment executable.
  ///
  /// @see [Environment.executable]
  String get executable => Environment.executable;

  /// Sets current environment executable.
  ///
  /// @see [Environment.executable]
  set executable(String executable) => Environment.executable = executable;

  /// Reads a defined environment variable.
  ///
  /// @see [Environment.get]
  String? get(String name) => Environment.get(name);

  /// Sets a defined environment variable.
  ///
  /// @see [Environment.set]
  void set(String name, String value) => Environment.set(name, value);

  /// Reads a file's content for a secret. The secret key is the name of the
  /// environment variable that is expected to specify the path of the file
  /// containing the secret.
  ///
  /// @see [Environment.secret]
  String? secret(String name) => Environment.secret(name);
}

/// Global environment helper.
///
/// @see [Environment.get]
String? env(String name) => Environment.get(name);

extension on String {
  // If the string is a file path, then return the file.
  File? get file {
    if (isEmpty) return null;
    final file = File(this);
    return file.existsSync() ? file : null;
  }
}

extension on DotEnv {
  /// Try to load file.
  void tryLoadFiles(Iterable<String> files) {
    for (final String(file: file) in files) {
      try {
        if (file != null) load([file.path]);
      } catch (_) {}
    }
  }

  /// Returns spry application environment string.
  String get env => Environment.get('SPRY_ENV') ?? Environment.development.name;

  /// Try load environment from the Spry environment.
  void tryLoadFrom(Environment env) {
    final Iterable<String> files = switch (env) {
      Environment.development => ['.env.development', '.env.dev'],
      Environment.testing => ['.env.testing', '.env.test'],
      Environment.production => ['.env.production', '.env.prod'],
    };

    tryLoadFiles(files);
  }
}

extension on CommandOption {
  /// Try setup command option.
  void trySetup(CommandInput input) {
    try {
      setup(input);
    } catch (_) {}
  }

  /// Parse command option creating a new environment.
  Environment parse(CommandInput input) {
    trySetup(input);
    if (value?.file != null) {
      _dotenv.tryLoadFiles([value!]);

      return createEnvironment(_dotenv.env);
    }

    final env = createEnvironment(value);
    _dotenv.tryLoadFrom(env);

    return env;
  }

  /// Creates a new environment from the value.
  Environment createEnvironment(String? value) {
    return switch (value?.trim()) {
      'production' || 'prod' => Environment.production,
      'testing' || 'test' => Environment.testing,
      _ => Environment.development,
    };
  }
}

/// Returns current working executable relative to the current working
/// directory.
String get _currentExecutable {
  if (NativeRuntime.buildId != null) {
    return relative(Platform.executable);
  }

  final script = relative(Platform.script.path);
  final executable = basename(Platform.executable);

  return '$executable $script';
}
