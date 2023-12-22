import 'package:consolekit/consolekit.dart';

import '../3.0/core/core.dart';
import '../3.0/environment/environment.dart';
import '../3.0/spry.dart';

void main(List<String> args) {
  final app = Spry(arguments: args);

  app.logger.onRecord.listen((record) {
    app.console.info(record.toString());
  });

  app.logger.info('Hello, world!');
  print(app.environment.executable);
  print(app.console.size);
  print(app.commands.commands);
}
