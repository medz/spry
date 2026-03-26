import 'package:spry/spry.dart';

Future<void> middleware(Event event, Next next) async {
  await next();
}
