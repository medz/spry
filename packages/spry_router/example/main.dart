import 'dart:io';

import 'package:spry/spry.dart';
import 'package:spry_router/spry_router.dart';

void main() async {
  final Spry spry = Spry();
  final Router router = Router();
  router.all('/', (context) {
    context.response
      ..status(HttpStatus.ok)
      ..send('Hello World!');
  });
  router.get('/hello/:name', (Context context) {
    final String name = context.request.param('name') as String;

    context.response
      ..status(HttpStatus.ok)
      ..send('Hello $name!');
  });

  final Router api = Router();
  api.get('/users', (Context context) {
    context.response
      ..status(HttpStatus.ok)
      ..send('Users');
  });
  api.get('/users/:id', (Context context) {
    final String id = context.request.param('id') as String;

    context.response
      ..status(HttpStatus.ok)
      ..send('User $id');
  });

  // Mount the API router to the `/api` path.
  router.mount('/api', router: api);

  // Mount a handler to the `/user` path.
  router.mount('/user', handler: (Context context) {
    context.response
      ..status(HttpStatus.ok)
      ..send('User');
  });

  // Merge the API router into the main router.
  router.merge(api);

  await spry.listen(router, port: 3000);

  print('Listening on http://localhost:3000');
}
