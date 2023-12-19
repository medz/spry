import 'dart:io';

import 'package:consolekit/consolekit.dart';
import 'package:dotenv/dotenv.dart';

import '../utilities/executeable.dart';

enum EnvironmentMode {
  development,
  testing,
  production;

  static EnvironmentMode fromString(String? value) {
    return switch (value?.trim()) {
      'development' || 'dev' => development,
      'testing' || 'test' => testing,
      'production' || 'prod' => production,
      _ => development,
    };
  }

  @override
  String toString() => '$key=$name';

  static String key = 'SPRY_ENV';
}

/// The environment the application is running in, i.e., development, testing,
/// or production.
class Environment {
  /// Internal environment instance. with the `dotenv` package.
  static final DotEnv _dotenv = DotEnv(includePlatformEnvironment: true);

  /// Current environment mode.
  late final EnvironmentMode mode;

  /// Current environment is development.
  bool get isDevelopment => mode == EnvironmentMode.development;

  /// Current environment is testing.
  bool get isTesting => mode == EnvironmentMode.testing;

  /// Current environment is production.
  bool get isProduction => mode == EnvironmentMode.production;

  /// The command-line arguments for this [Environment].
  Iterable<String> get arguments => commandInput;

  /// Creates a new [Environment] instance.
  Environment._(
    Iterable<String> arguments, {
    String? executable,
    EnvironmentMode? mode,
  }) {
    this.mode = switch (mode) {
      EnvironmentMode mode => mode,
      _ => EnvironmentMode.development,
    };

    final exe = switch (executable) {
      String executable when executable.isNotEmpty => executable,
      _ => currentExecutable,
    };

    commandInput = CommandInput(exe, List.from(arguments));

    if (!_dotenv.isDefined(EnvironmentMode.key)) {
      _dotenv.addAll({EnvironmentMode.key: this.mode.name});
    }
  }

  /// Exposes the `Environment`'s `arguments` property as a `CommandInput`.
  late CommandInput commandInput;

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
  ///  final app = Application(environment: environment);
  ///
  ///  if (environment.isDevelopment) {
  ///     app.middleware.use(DebugMiddleware());
  ///  }
  /// }
  /// ```
  factory Environment.detect({
    Iterable<String>? arguments,
    String? executable,
  }) {
    final args = switch (arguments) {
      Iterable<String> arguments when arguments.isNotEmpty => arguments,
      _ => Platform.executableArguments,
    };
    final exe = switch (executable) {
      String executable when executable.isNotEmpty => executable,
      _ => currentExecutable,
    };
    final input = CommandInput(exe, args);

    final options = CommandOption(
      'env',
      short: 'e',
      description: 'The environment to run the Spry application in, i.e., '
          'development, testing, or production. Defaults to "development". If you customize the value is a dot env file, e.g., `dart run main.dart -e .env`.',
      optional: true,
    )..trySetup(input);

    // Override the environment.
    final mode = switch (options.isDotEnvFile) {
      true => options.loadEnvFile(_dotenv),
      _ => _dotenv.autoLoadEnvFiles(EnvironmentMode.fromString(options.value)),
    };

    return Environment._(input, executable: exe, mode: mode);
  }

  /// Creates a new [Environment] instance from the spry environment.
  factory Environment._fromMode({
    required EnvironmentMode mode,
    Iterable<String>? arguments,
    String? executable,
  }) {
    final args = switch (arguments) {
      Iterable<String> arguments when arguments.isNotEmpty => arguments,
      _ => Platform.executableArguments,
    };
    final exe = switch (executable) {
      String executable when executable.isNotEmpty => executable,
      _ => currentExecutable,
    };

    _dotenv.autoLoadEnvFiles(mode);

    return Environment._(
      args,
      executable: exe,
      mode: mode,
    );
  }

  /// Creates a production [Environment] instance.
  factory Environment.production({
    Iterable<String>? arguments,
    String? executable,
  }) =>
      Environment._fromMode(
        mode: EnvironmentMode.production,
        arguments: arguments,
        executable: executable,
      );

  /// Creates a testing [Environment] instance.
  factory Environment.testing({
    Iterable<String>? arguments,
    String? executable,
  }) =>
      Environment._fromMode(
        mode: EnvironmentMode.testing,
        arguments: arguments,
        executable: executable,
      );

  /// Creates a development [Environment] instance.
  factory Environment.development({
    Iterable<String>? arguments,
    String? executable,
  }) =>
      Environment._fromMode(
        mode: EnvironmentMode.development,
        arguments: arguments,
        executable: executable,
      );

  /// Static helper, Reads a defined environment variable.
  ///
  /// - If using `dart --define=K=V` or `dart -D K=V`, then the value of `K` is
  ///  returned.
  /// - If defined in a `.env` file, then the value of `K` is returned.
  /// - otherwise, `Platform.environment[K]` is returned.
  static String get(String name, [String defaultsTo = ""]) {
    if (bool.fromEnvironment(name)) {
      return String.fromEnvironment(name, defaultValue: defaultsTo);
    }

    return _dotenv[name] ?? Platform.environment[name] ?? defaultsTo;
  }

  /// Returns the current platform environment.
  ///
  /// @see [Platform.environment]
  static Map<String, String> get platform => Platform.environment;

  /// Reads a file's content for a secret. The secret key is the name of the
  /// environment variable that is expected to specify the path of the file
  /// containing the secret.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// void configure(Application app) {
  ///   /// ...
  ///   final jwtSecret = Environment.secret('JWT_SECRET');
  ///
  ///   app.middleware.use(JwtAuthentication(jwtSecret));
  /// }
  /// ```
  ///
  /// **NOTE**: If the environment variable is not defined, or the file does not
  /// exist, then `null` is returned.
  static String? secret(String name) {
    return switch (get(name).trim()) {
      String value when value.isNotEmpty =>
        File(value).readAsStringSyncOrNull(),
      _ => null,
    };
  }
}

/// Public environment reader.
///
/// @see [Environment.get]
String env(String name, [String defaultsTo = ""]) =>
    Environment.get(name, defaultsTo);

extension on File {
  /// Sync read contents as string or null.
  String? readAsStringSyncOrNull() {
    if (!existsSync()) return null;

    return readAsStringSync();
  }
}

extension on DotEnv {
  /// Loads a environment file name in current working directory.
  ///
  /// If File not found, no error is thrown.
  void loadEnvFile(Iterable<String> names) {
    for (final name in names) {
      final file = File(name);
      if (file.existsSync()) {
        try {
          load([file.path]);
        } catch (_) {
          // ignore
        }
      }
    }
  }

  /// Loads a environment and returns override [SpryEnv].
  EnvironmentMode autoLoadEnvFiles(EnvironmentMode env) {
    final names = <String>[
      '.env',
      ...switch (env) {
        EnvironmentMode.development => ['.env.development', '.env.dev'],
        EnvironmentMode.testing => ['.env.testing', '.env.test'],
        EnvironmentMode.production => ['.env.production', '.env.prod'],
      },
    ];
    loadEnvFile(names);

    return switch (this['SPRY_ENV']) {
      String value when value.isNotEmpty => EnvironmentMode.fromString(value),
      _ => env,
    };
  }
}

extension on CommandOption {
  void trySetup(CommandInput input) {
    try {
      setup(input);
    } catch (_) {
      // ignore
    }
  }

  bool get isDotEnvFile {
    if (value == null) return false;

    return File(value!).existsSync();
  }

  EnvironmentMode loadEnvFile(DotEnv env) {
    if (value?.isNotEmpty == true) {
      env.loadEnvFile([value!]);
    }

    return switch (env[EnvironmentMode.key]) {
      String value when value.isNotEmpty => EnvironmentMode.fromString(value),
      _ => EnvironmentMode.development,
    };
  }
}
