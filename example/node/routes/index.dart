import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({
    'example': 'node',
    'runtime': event.context.runtime.name,
    'path': event.url.path,
  });
}
