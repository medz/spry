import 'package:spry/spry.dart';

import '../../../db.dart';

Future<Response> handler(Event event) async {
  final id = int.tryParse(event.params.required('id'));
  if (id == null) {
    return Response.json({
      'error': 'invalid_id',
      'message': 'The todo id must be an integer.',
    }, ResponseInit(status: 400));
  }

  final todo = await toggleTodo(id);
  if (todo == null) {
    return Response.json({
      'error': 'not_found',
      'message': 'No todo exists for id $id.',
    }, ResponseInit(status: 404));
  }

  return Response.json({'item': todo});
}
