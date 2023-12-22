import 'dart:async';

import 'package:consolekit/consolekit.dart';
import 'package:logging/logging.dart';
import 'package:spry/src/core/core.dart';
import 'package:spry/src/core/running.dart';

import '../server/bind_address.dart';
import '../server/servers.dart';
import 'command_context+application.dart';

class ServeCommand extends Command {
  @override
  String get description => 'Begins serving the app over HTTP.';

  final hostname = CommandOption(
    'hostname',
    short: 'h',
    optional: true,
    description: 'The hostname to start the server on.',
  );

  final port = CommandOption(
    'port',
    short: 'p',
    optional: true,
    description: 'The port to start the server on.',
  );

  final unixSocket = CommandOption(
    'unix-socket',
    optional: true,
    description:
        'Set the path for the unix domain socket file the server will bind to.',
  );

  final shared = CommandFlag(
    'shared',
    description: 'Set the socket to be a shared socket.',
  );

  final help = CommandFlag('help',
      short: 'h', description: 'Displat this help information.');

  @override
  Iterable<CommandOption> get options => [hostname, port, unixSocket];

  @override
  Iterable<CommandFlag> get flags => [shared, help];

  @override
  FutureOr<void> run(CommandContext context) async {
    if (help.value) {
      return printHelp(context);
    }

    final application = context.application;
    application.servers.shared = shared.value;

    final configuration = (
      hostname.value,
      port.value != null ? int.tryParse(port.value!) : null,
      unixSocket.value
    );
    application.servers.address = switch (configuration) {
      (_, _, String path) => BindAddress.unix(path),
      (String hostname, int port, _) => BindAddress.host(hostname, port),
      (String hostname, _, _) =>
        BindAddress.host(hostname, application.servers.port),
      (_, int port, _) => BindAddress.host(application.servers.hostname, port),
      _ => application.servers.address,
    };

    final subscription = application.logger.onRecord.listen((event) {
      final level = switch (event.level) {
        Level.INFO => ConsoleText('[INFO]', ConsoleStyle.info),
        Level.WARNING => ConsoleText('[WARNING]', ConsoleStyle.warning),
        Level.SEVERE => ConsoleText('[SEVERE]', ConsoleStyle.error),
        _ => ConsoleText('[${event.level.toString()}]', ConsoleStyle.plain),
      };
      context.console.output(level, newline: false);
      context.console.plain(' ', newline: false);

      final name = ConsoleText(
          event.loggerName, ConsoleStyle(color: ConsoleColor.gray, bold: true));
      context.console.output(name, newline: false);
      context.console.plain(' ', newline: false);

      final datetime = ConsoleText(event.time.toString());
      context.console.plain('(', newline: false);
      context.console.output(datetime, newline: false);
      context.console.plain(') - ', newline: false);

      final message = ConsoleText(event.message);
      context.console.output(message, newline: true);
    });

    final completer = Completer<void>();
    application.running = Running(completer);

    application.container.set<ServeCommand>(this, onShutdown: (_) {
      completer.complete();
      subscription.cancel();
    });

    await application.server.start();

    context.console.success(
        '🚀 Application served on http://${application.servers.address}');
  }
}
