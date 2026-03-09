import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({
    'fallback': true,
    'slug': event.params.wildcard,
  }, status: 404);
}
