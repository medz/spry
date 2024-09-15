import '_constants.dart';
import 'http/response.dart';
import 'types.dart';
import 'utils/_create_response_with.dart';

Future<Response> next(Event event) async {
  final handler = event.locals[kNext];

  // Remove current handler of event.
  event.locals.remove(kNext);

  return switch (handler) {
    Handler handler => createResponseWith(event, handler(event)),
    _ => Response(null, status: 204),
  };
}
