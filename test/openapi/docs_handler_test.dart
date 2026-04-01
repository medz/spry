import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';
import 'package:test/test.dart';

void main() {
  group('defineScalarHandler', () {
    test('returns an html response using the provided docs config', () async {
      final app = Spry(
        routes: {
          '/_docs': {
            HttpMethod.get: defineScalarHandler(
              url: '/openapi.json',
              title: 'My API',
              theme: 'moon',
              layout: 'classic',
            ),
          },
        },
      );

      final response = await app.fetch(_request('/_docs'), _context());
      final body = await response.text();

      expect(response.status, 200);
      expect(response.headers.get('content-type'), 'text/html; charset=utf-8');
      expect(body, contains('<title>My API</title>'));
      expect(body, contains('<div id="app"></div>'));
      expect(body, contains('@scalar/api-reference'));
      expect(body, contains("Scalar.createApiReference('#app', {"));
      expect(body, contains('"url":"/openapi.json"'));
      expect(body, contains('"theme":"moon"'));
      expect(body, contains('"layout":"classic"'));
    });

    test('accepts absolute urls and escapes html in titles', () async {
      final app = Spry(
        routes: {
          '/_docs': {
            HttpMethod.get: defineScalarHandler(
              url: 'https://api.example.com/openapi.json',
              title: '<Docs & API>',
            ),
          },
        },
      );

      final response = await app.fetch(_request('/_docs'), _context());
      final body = await response.text();

      expect(body, contains('<title>&lt;Docs &amp; API&gt;</title>'));
      expect(body, contains('"url":"https://api.example.com/openapi.json"'));
    });
  });
}

Request _request(String path, {String method = 'GET'}) {
  return Request(
    Uri.parse('https://example.com$path'),
    RequestInit(method: HttpMethod.parse(method)),
  );
}

RequestContext _context() {
  return RequestContext(
    runtime: const RuntimeInfo(name: 'test', kind: 'server'),
    capabilities: const RuntimeCapabilities(
      streaming: true,
      websocket: false,
      fileSystem: false,
      backgroundTask: true,
      rawTcp: false,
      nodeCompat: false,
    ),
    onWaitUntil: (_) {},
  );
}
