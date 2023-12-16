import 'package:logging/logging.dart';

import 'core/container.dart';

final class Application {
  Application() {
    logger = Logger('spry.application');
    container = Container(logger: logger);
  }

  /// Returns the container for the application.
  late Container container;

  /// Returns the logger for the application.
  late Logger logger;
}
