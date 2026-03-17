import 'package:spry/spry.dart';

Response onError(Object error, StackTrace stackTrace, Event event) {
  if (error case NotFoundError()) {
    return Response.json({
      'error': 'not_found',
      'path': event.url.path,
    }, ResponseInit(status: 404));
  }

  return Response.json({
    'error': '$error',
    'path': event.url.path,
  }, ResponseInit(status: 500));
}
