import 'package:spry/spry.dart';

Response onError(Object error, StackTrace stackTrace, Event event) {
  if (error case NotFoundError()) {
    return Response.json({
      'error': 'not_found',
      'path': event.request.url.path,
    }, status: 404);
  }
  if (error case HTTPError()) {
    return error.toResponse();
  }

  return Response.json({
    'error': 'internal_server_error',
    'path': event.request.url.path,
  }, status: 500);
}
