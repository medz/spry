import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({
    'message': 'hello from spry',
    'runtime': event.context.runtime.name,
    'path': event.url.path,
  });
}
