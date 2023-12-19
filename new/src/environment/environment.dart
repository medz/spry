import 'dart:io';

import 'package:consolekit/consolekit.dart';
import 'package:dotenv/dotenv.dart';

import '../utilities/executeable.dart';

enum SpryEnv {
  development,
  testing,
  production;

  static SpryEnv fromString(String? value) {
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

  /// Current environment.
  late final SpryEnv env;

  /// Current environment is development.
  bool get isDevelopment => env == SpryEnv.development;

  /// Current environment is testing.
  bool get isTesting => env == SpryEnv.testing;

  /// Current environment is production.
  bool get isProduction => env == SpryEnv.production;

  /// The environment name.
  final String name;

  /// The command-line arguments for this [Environment].
  Iterable<String> get arguments => commandInput;

  /// Creates a new [Environment] instance.
  Environment._(
    this.name,
    Iterable<String> arguments, {
    String? executable,
    SpryEnv? env,
  }) {
    this.env = switch (env) {
      SpryEnv env => env,
      _ => SpryEnv.development,
    };

    final exe = switch (executable) {
      String executable when executable.isNotEmpty => executable,
      _ => currentExecutable,
    };

    commandInput = CommandInput(exe, List.from(arguments));

    if (!_dotenv.isDefined(SpryEnv.key)) {
      _dotenv.addAll({SpryEnv.key: this.env.name});
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
    final env = switch (options.isDotEnvFile) {
      true => options.loadEnvFile(_dotenv),
      _ => _dotenv.autoLoadEnvFiles(SpryEnv.fromString(options.value)),
    };

    return Environment._(env.name, input, executable: exe, env: env);
  }

  /// Creates a new [Environment] instance from the spry environment.
  factory Environment._fromEnv({
    required SpryEnv env,
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

    _dotenv.autoLoadEnvFiles(env);

    return Environment._(
      env.name,
      args,
      executable: exe,
      env: env,
    );
  }

  /// Creates a production [Environment] instance.
  factory Environment.production({
    Iterable<String>? arguments,
    String? executable,
  }) =>
      Environment._fromEnv(
        env: SpryEnv.production,
        arguments: arguments,
        executable: executable,
      );

  /// Creates a testing [Environment] instance.
  factory Environment.testing({
    Iterable<String>? arguments,
    String? executable,
  }) =>
      Environment._fromEnv(
        env: SpryEnv.testing,
        arguments: arguments,
        executable: executable,
      );

  /// Creates a development [Environment] instance.
  factory Environment.development({
    Iterable<String>? arguments,
    String? executable,
  }) =>
      Environment._fromEnv(
        env: SpryEnv.development,
        arguments: arguments,
        executable: executable,
      );

  /// Static helper, Reads a defined environment variable.
  ///
  /// - If using `dart --define=K=V` or `dart -D K=V`, then the value of `K` is
  ///  returned.
  /// - If defined in a `.env` file, then the value of `K` is returned.
  /// - otherwise, `Platform.environment[K]` is returned.
  static String? get(String name, [String defaultsTo = ""]) {
    if (bool.fromEnvironment(name)) {
      return String.fromEnvironment(name, defaultValue: defaultsTo);
    }

    return _dotenv[name] ?? Platform.environment[name] ?? defaultsTo;
  }
}

/// Public environment reader.
///
/// @see [Environment.get]
String? env(String name, [String defaultsTo = ""]) =>
    Environment.get(name, defaultsTo);

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
  SpryEnv autoLoadEnvFiles(SpryEnv env) {
    final names = <String>[
      '.env',
      ...switch (env) {
        SpryEnv.development => ['.env.development', '.env.dev'],
        SpryEnv.testing => ['.env.testing', '.env.test'],
        SpryEnv.production => ['.env.production', '.env.prod'],
      },
    ];
    loadEnvFile(names);

    return switch (this['SPRY_ENV']) {
      String value when value.isNotEmpty => SpryEnv.fromString(value),
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

  SpryEnv loadEnvFile(DotEnv env) {
    if (value?.isNotEmpty == true) {
      env.loadEnvFile([value!]);
    }

    return switch (env[SpryEnv.key]) {
      String value when value.isNotEmpty => SpryEnv.fromString(value),
      _ => SpryEnv.development,
    };
  }
}
