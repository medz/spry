import 'package:consolekit/consolekit.dart';
import 'package:logging/logging.dart';

import 'commands/command_context+application.dart';
import 'commands/routes_command.dart';
import 'commands/serve_command.dart';
import 'core/container.dart';
import 'core/core.dart';
import 'environment/environment.dart';
import 'routing/route.dart';
import 'routing/routes_builder.dart';
import 'routing/spry_routes_props.dart';

class Spry implements RoutesBuilder {
  /// Current spry framework version.
  static const String version = '3.0.0';

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

  /// When called, this will asynchronously execute the startup command
  /// provided through an argument. If no startup command is provided, the
  /// default is used. Under normal circumstances, this will start running
  /// Spry's webserver.
  Future<void> startup() async {
    // Configure the application commands.
    commands.use('serve', ServeCommand());
    commands.use('routes', RoutesCommand());
    final group = commands.group();

    // Create console context.
    final context = CommandContext(
      console,
      CommandInput(environment.executable, Environment.arguments),
    );

    // Setup the application into console context.
    context.application = this;

    return console.runWithContext(group, context);
  }
}
