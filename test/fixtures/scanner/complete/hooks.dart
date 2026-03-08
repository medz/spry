import 'package:spry/spry.dart';

Future<void> onStart(ServerLifecycleContext context) async {
  print(context.runtime.name);
}
