import 'package:logging/logging.dart';

import 'core/container.dart';
import 'environment/environment.dart';
import 'routing/route.dart';
import 'routing/routes_builder.dart';
import 'routing/spry_routes_props.dart';

class Spry implements RoutesBuilder {
  /// Current Spry application environment.
  late final Environment environment;

  /// Current Spry application logger.
  final Logger logger = Logger('spry');

  /// Global storage container.
  late final Container container;

  Spry({
    Environment? environment,
    String? executable,
    Iterable<String>? arguments,
  }) : environment = environment ??
            Environment.detect(executable: executable, arguments: arguments) {
    this.environment.arguments = arguments ?? this.environment.arguments;
    this.environment.executable = executable ?? this.environment.executable;

    /// Setup global storage container.
    container = Container(logger);
  }

  @override
  void addRoute(Route route) => routes.addRoute(route);
}
