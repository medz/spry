import '_constants.dart';
import 'http/response.dart';
import 'types.dart';
import 'utils/_create_response_with.dart';

/// Call next handler in [Spry.stack].
Future<Response> next(Event event) async {
  final handler = event.get(kNext);
  event.remove(kNext);

  return switch (handler) {
    Handler handler => createResponseWith(event, handler(event)),
    _ => Response(null, status: 204),
  };
}
