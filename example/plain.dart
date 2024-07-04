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

  router.group(route: 'demo', (routes) {
    routes.all('haha', defineHandler((event) {
      print('3');
    }));

    routes.all('/', defineHandler((event) {
      print('demo root');
    }));
  });

  app.use(router);

  final handler = toPlainHandler(app);
  final request = createPlainRequest(
    method: 'get',
    uri: Uri.parse('/demo/haha'),
  );
  await handler(request);
}
