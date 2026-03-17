import 'package:spry/spry.dart';

import '../db.dart';

Future<Response> handler(Event event) async {
  final items = await listTodos();
  return Response.json({
    'items': items,
    'total': items.length,
    'runtime': event.context.runtime.name,
  });
}
