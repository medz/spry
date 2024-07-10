import 'package:spry/spry.dart';
import 'package:spry/plain.dart';
import 'package:spry_cookie/spry_cookie.dart';
import 'package:test/test.dart';

void main() async {
  const plain = PlainPlatform();

  test('cookies get set correctly', () async {
    final app = Spry()..use(cookie());

    app.get('/test', (event) {
      event.cookies.set('foo', 'bar');

      expect(event.cookies.get('foo'), equals('bar'));
    });

    final handler = plain.createHandler(app);
    final request = PlainRequest(method: 'get', uri: Uri(path: "/test"));
    final response = await handler(request);

    expect(response.headers.get('set-cookie'), 'foo=bar');
  });

  test('should set multiple cookies', () async {
    final app = Spry();

    app.use(cookie());
    app.use((event) async {
      event.cookies.set('middleware', '1');

      final response = await next(event);

      expect(event.cookies.get('foo'), equals('foo'));
      expect(event.cookies.get('bar'), equals('bar'));
      expect(event.cookies.get('wee'), equals('wer'));
      expect(event.cookies.get('middleware'), isNull);

      return response;
    });
    app.get('/test', (event) {
      expect(event.cookies.get('middleware'), equals('1'));

      event.cookies
        ..set('foo', 'foo')
        ..set('bar', 'bar')
        ..set('wee', 'wer')
        ..delete('middleware');
    });

    final handler = plain.createHandler(app);
    final request = PlainRequest(method: 'get', uri: Uri(path: '/test'));
    final response = await handler(request);
    final cookies = response.headers.get('set-cookie');

    expect(cookies, contains("foo=foo"));
    expect(cookies, contains("bar=bar"));
    expect(cookies, contains("wee=wer"));
    expect(cookies, contains("middleware=;"));
  });
}
