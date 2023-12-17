import 'package:logging/logging.dart';

import 'core/container.dart';
import 'routing/route.dart';
import 'routing/routes.dart';
import 'routing/routes_builder.dart';

final class Application implements RoutesBuilder {
  Application() {
    logger = Logger('spry.application');
    container = Container(logger: logger);
  }

  /// Returns the container for the application.
  late Container container;

  /// Returns the logger for the application.
  late Logger logger;

  @override
  void add(Route route) => routes.add(route);
}
