import '_constants.dart';
import 'types.dart';
import 'utils/_create_response_with.dart';

Future<void> next(Event event) async {
  final handler = event.locals[kNext];

  // Remove current handler of event.
  event.locals.remove(kNext);

   switch (handler) {
    Handler handler => createResponseWith(event, handler(event)),
    _ => event.response,
  };
}
