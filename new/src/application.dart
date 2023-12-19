import 'package:logging/logging.dart';

import 'environment/environment.dart';
import 'utilities/storage.dart';

class Application {
  /// Returns the current application logger.
  Logger get logger => _logger;
  final _logger = Logger('spry.application');

  /// Returns the current application storage.
  Storage get storage => _storage;
  late final Storage _storage;

  /// Current application environment.
  late Environment environment;

  /// Creates a new Spry [Application].
  ///
  /// If [environment] is not provided, the application will attempt to detect
  /// the environment from the command-line arguments.
  ///
  /// **NOTE**: The [arguments] and [executable] parameters are only used when
  /// [environment] is not provided.
  Application({
    Environment? environment,
    Iterable<String>? arguments,
    String? executable,
  }) {
    this.environment = switch (environment) {
      Environment environment => environment,
      _ => Environment.detect(arguments: arguments, executable: executable),
    };

    _storage = Storage(logger);
  }
}

typedef Spry = Application;
