import 'dart:async';

import 'package:consolekit/consolekit.dart';

/// Displays all routes registered to the [Application]'s [Router] in an
/// ASCII-formatted table.
///
/// ```sh
/// dart run routes
///
/// +------+-----------------------+
/// | GET  | /users                |
/// +------+-----------------------+
/// | POST | /users                |
/// +------+-----------------------+
/// | GET  | /users/:user_id       |
/// +------+-----------------------+
/// | GET  | /users/:user_id/posts |
/// +------+-----------------------+
/// ```
class RoutesCommand extends Command {
  @override
  String get description => 'Displays all registered routes';

  @override
  FutureOr<void> run(CommandContext context) {
    // TODO: implement run
    throw UnimplementedError();
  }
}
