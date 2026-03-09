import 'package:ht/ht.dart' show HttpMethod;
import 'package:spry/spry.dart';

final app = Spry(
  routes: {
    '/': {
      null: rootHandler,
    },
    '/users/:id': {
      HttpMethod.get: userHandler,
    },
  },
  middleware: [
    MiddlewareRoute(path: '/*', handler: requestLogger),
  ],
  errors: [
    ErrorRoute(path: '/*', handler: apiError),
  ],
  fallback: {
    null: notFound,
  },
  publicDir: 'public',
);

Future<Response> requestLogger(Event event, Next next) async {
  return next();
}

Response rootHandler(Event event) {
  return Response.json({'ok': true});
}

Response userHandler(Event event) {
  return Response.json({'id': event.params.required('id')});
}

Response apiError(Object error, StackTrace stackTrace, Event event) {
  if (error case HTTPError()) {
    return error.toResponse();
  }

  return Response.json({'error': 'internal_server_error'}, status: 500);
}

Response notFound(Event event) {
  return Response.json({'error': 'not_found'}, status: 404);
}
