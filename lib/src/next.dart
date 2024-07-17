import '_constants.dart';
import 'response.dart';
import 'types.dart';

Future<Response> next(Event event) async {
  final handler = event.get(kNext);
  event.remove(kNext);

  return switch (handler) {
    Handler<Response> handler => handler(event),
    _ => Response(null, status: 204),
  };
}
