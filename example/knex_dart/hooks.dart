import 'package:spry/spry.dart';

import 'db.dart';

Future<void> onStart(ServerLifecycleContext context) async {
  await openDatabase();
  print('Spry knex_dart example started: ${context.runtime.name}');
}

Future<void> onStop(ServerLifecycleContext context) async {
  await closeDatabase();
  print('Spry knex_dart example stopped: ${context.runtime.name}');
}
