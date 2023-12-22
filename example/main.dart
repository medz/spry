import 'package:consolekit/consolekit.dart';

import '../src/core/core.dart';
import '../src/environment/environment.dart';
import '../src/spry.dart';

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
