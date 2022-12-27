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

  await spry.listen(router, port: 3000);

  print('Listening on http://localhost:3000');
}
