import 'package:spry/spry.dart';

Response handler(Event event) {
  return Response.json({
    'example': 'knex_dart',
    'runtime': event.context.runtime.name,
    'database': 'sqlite',
    'endpoints': ['GET /todos', 'POST /todos', 'POST /todos/:id/toggle'],
  });
}
