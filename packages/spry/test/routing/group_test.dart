import 'package:spry/plain.dart';
import 'package:spry/spry.dart';
import 'package:test/test.dart';

void main() {
  test('group route', () async {
    final app = Spry();

    app.group(route: '/api', (routes) {
      routes.get('1', (_) => '/api/1');
      routes.get('2', (_) => '/api/2');
      routes.get(':name', (event) => '/api/${event.params('name')}');
    });

    final handler = app.toPlainHandler();

    final paths = ['/api/1', '/api/2', '/api/name', '/api/test'];
    for (final path in paths) {
      final request = PlainRequest(method: 'get', uri: Uri(path: path));
      final response = await handler(request);

      expect(await response.text(), equals(path));
    }
  });

  test('group uses', () async {
    final app = Spry();
    final group1 = app.groupd(uses: [
      ClosureHandler((event) async {
        event.locals.set('group', 1);

        return next(event);
      }),
    ]);
    final group2 = app.groupd(uses: [
      ClosureHandler((event) async {
        event.locals.set('group', 2);

        return next(event);
      }),
    ]);

    group1.get('/test1', (event) => event.locals.get('group'));
    group2.get('/test2', (event) => event.locals.get('group'));

    final handler = app.toPlainHandler();
    final routes = [('/test1', '1'), ('/test2', '2')];
    for (final route in routes) {
      final request = PlainRequest(method: 'get', uri: Uri(path: route.$1));
      final response = await handler(request);

      expect(await response.text(), equals(route.$2));
    }
  });
}
