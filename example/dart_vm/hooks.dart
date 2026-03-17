import 'package:spry/spry.dart';

Future<void> onStart(ServerLifecycleContext context) async {
  print('Spry dart_vm example started: ${context.runtime.name}');
}
