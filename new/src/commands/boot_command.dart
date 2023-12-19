import 'dart:async';

import 'package:consolekit/consolekit.dart';

class BootCommand extends Command {
  @override
  String get description => "Boots the application's providers.";

  @override
  FutureOr<void> run(CommandContext context) {
    context.console.success('Done.');
  }
}
