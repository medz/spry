import 'package:spry/spry.dart';
import 'package:spry/router.dart';

final spry = Spry();
final router = Router();

void main() async {
  router.get('/hello/:name', (context) {
    final name = context.request.params['name'];

    context.response.text('Hello $name');
  });

  final server = await spry.listen(router);
  print('Listening on http://127.0.0.1:${server.port}');
}
