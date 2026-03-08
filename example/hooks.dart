import 'package:spry/spry.dart';

Future<void> onStart(ServerLifecycleContext context) async {
  print('Spry example started: ${context.runtime.name}');
}
