import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({
    'page': 'about',
    'method': event.method,
  });
}
