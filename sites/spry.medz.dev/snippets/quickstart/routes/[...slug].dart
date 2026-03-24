import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({
    'fallback': true,
    'slug': event.params.get('slug'),
  }, ResponseInit(status: 404));
}
