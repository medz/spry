import 'package:spry/spry.dart';

Future<Response> middleware(Event event, Next next) async {
  event.locals.set(
    #requestId,
    DateTime.now().microsecondsSinceEpoch.toString(),
  );
  return next();
}
