import 'package:logging/logging.dart';

import 'utilities/storage.dart';

class Application {
  /// Returns the current application logger.
  Logger get logger => _logger;
  final _logger = Logger('spry.application');

  /// Returns the current application storage.
  Storage get storage => _storage;
  late final Storage _storage;

  Application() {
    _storage = Storage(logger);
  }
}
