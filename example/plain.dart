import 'package:spry/plain.dart';
import 'package:spry/spry.dart';

main() async {
  final app = createApp();

  app.use(defineHandler((event) {
    print(1);
    next();
  }));

  app.use(defineHandler((event) {
    print(event.method);
    print(event.uri.path);
    next();
  }));

  final router = createRouter();

  router.get('/users/:name', defineHandler((event) {
    print(getRouteParam(event, 'name'));
  }));

  app.use(router);

  final handler = toPlainHandler(app);
  final request = createPlainRequest(
    method: 'get',
    uri: Uri.parse('spry:///users/seven?a=2'),
  );
  await handler(request);
}
