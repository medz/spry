import 'package:spry/spry.dart';

import '../db.dart';

Future<Response> handler(Event event) async {
  try {
    final payload = await event.request.json<Object?>();
    if (payload is! Map) {
      return Response.json({
        'error': 'invalid_payload',
        'message': 'Expected a JSON object with a title field.',
      }, ResponseInit(status: 400));
    }

    final title = payload['title'];
    if (title is! String || title.trim().isEmpty) {
      return Response.json({
        'error': 'invalid_title',
        'message': 'The title field must be a non-empty string.',
      }, ResponseInit(status: 400));
    }

    final todo = await createTodo(title);
    return Response.json({'item': todo}, ResponseInit(status: 201));
  } on FormatException {
    return Response.json({
      'error': 'invalid_json',
      'message': 'Request body must be valid JSON.',
    }, ResponseInit(status: 400));
  }
}
