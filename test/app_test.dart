import 'dart:io' as io;

import 'package:spry/app.dart';
import 'package:spry/osrv.dart';
import 'package:spry/spry.dart' show Event;
import 'package:test/test.dart';

void main() {
  group('Spry.fetch', () {
    test('returns a text response from a string handler', () async {
      final app = Spry(
        routes: {
          '/': {null: (_) => _textResponse('hello')},
        },
      );

      final response = await app.fetch(_request('/'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'hello');
      expect(response.headers.get('content-type'), contains('text/plain'));
    });

    test('serves public assets before route handlers', () async {
      final root = await io.Directory.systemTemp.createTemp(
        'spry_public_test_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });
      await io.File('${root.path}/hello.txt').writeAsString('static');

      final app = Spry(
        publicDir: root.path,
        routes: {
          '/hello.txt': {HttpMethod.get: (_) => _textResponse('route')},
        },
      );

      final response = await app.fetch(_request('/hello.txt'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'static');
      expect(response.headers.get('content-type'), contains('text/plain'));
    });

    test('serves index.html for directory requests', () async {
      final root = await io.Directory.systemTemp.createTemp(
        'spry_public_test_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });
      await io.Directory('${root.path}/docs').create(recursive: true);
      await io.File('${root.path}/docs/index.html').writeAsString('docs');

      final app = Spry(publicDir: root.path);
      final response = await app.fetch(_request('/docs/'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'docs');
      expect(response.headers.get('content-type'), contains('text/html'));
    });

    test('injects route params into the event', () async {
      final app = Spry(
        routes: {
          '/users/:id': {
            HttpMethod.get: (event) =>
                _textResponse(event.params.required('id')),
          },
        },
      );

      final response = await app.fetch(_request('/users/42'), _context());

      expect(response.status, 200);
      expect(await response.text(), '42');
    });

    test('injects named catch-all params without wildcard aliasing', () async {
      final app = Spry(
        routes: {
          '/**:slug': {
            HttpMethod.get: (event) =>
                _textResponse(event.params.get('slug') ?? 'missing'),
          },
        },
      );

      final response = await app.fetch(_request('/docs/api/event'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'docs/api/event');
    });

    test('uses fallback when no route matches', () async {
      final app = Spry(fallback: {null: (_) => _textResponse('fallback')});

      final response = await app.fetch(_request('/missing'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'fallback');
    });

    test('returns 404 when no route or fallback matches', () async {
      final app = Spry();

      final response = await app.fetch(_request('/missing'), _context());

      expect(response.status, 404);
    });

    test('converts thrown HTTPError into a response', () async {
      final app = Spry(
        routes: {
          '/': {null: (_) => throw const HTTPError(401, body: 'unauthorized')},
        },
      );

      final response = await app.fetch(_request('/'), _context());

      expect(response.status, 401);
      expect(await response.text(), 'unauthorized');
    });

    test('routes not-found through the error pipeline', () async {
      final app = Spry(
        errors: [
          ErrorRoute(
            path: '/**',
            handler: (error, stackTrace, event) {
              expect(error, isA<NotFoundError>());
              return _textResponse('not-found');
            },
          ),
        ],
      );

      final response = await app.fetch(_request('/missing'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'not-found');
    });

    test('wraps the handler with middleware from outer to inner', () async {
      final log = <String>[];
      final app = Spry(
        routes: {
          '/api/demo': {
            HttpMethod.get: (_) {
              log.add('handler');
              return _textResponse('ok');
            },
          },
        },
        middleware: [
          MiddlewareRoute(
            path: '/**',
            handler: (event, next) async {
              log.add('global before');
              final response = await next();
              log.add('global after');
              return response;
            },
          ),
          MiddlewareRoute(
            path: '/api/**',
            handler: (event, next) async {
              log.add('api before');
              final response = await next();
              log.add('api after');
              return response;
            },
          ),
        ],
      );

      final response = await app.fetch(_request('/api/demo'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'ok');
      expect(log, [
        'global before',
        'api before',
        'handler',
        'api after',
        'global after',
      ]);
    });

    test('uses the nearest error handler first', () async {
      final app = Spry(
        routes: {
          '/api/demo': {HttpMethod.get: (_) => throw StateError('boom')},
        },
        errors: [
          ErrorRoute(
            path: '/**',
            handler: (error, stackTrace, event) => _textResponse('root'),
          ),
          ErrorRoute(
            path: '/api/**',
            handler: (error, stackTrace, event) => _textResponse('api'),
          ),
        ],
      );

      final response = await app.fetch(_request('/api/demo'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'api');
    });

    test(
      'bubbles to the next outer error handler when the nearest throws',
      () async {
        final app = Spry(
          routes: {
            '/api/demo': {HttpMethod.get: (_) => throw StateError('boom')},
          },
          errors: [
            ErrorRoute(
              path: '/**',
              handler: (error, stackTrace, event) => _textResponse('root'),
            ),
            ErrorRoute(
              path: '/api/**',
              handler: (error, stackTrace, event) => throw StateError('inner'),
            ),
          ],
        );

        final response = await app.fetch(_request('/api/demo'), _context());

        expect(response.status, 200);
        expect(await response.text(), 'root');
      },
    );

    test(
      'event.url returns the same Uri instance on repeated access',
      () async {
        late Event capturedEvent;
        final app = Spry(
          routes: {
            '/': {
              null: (event) {
                capturedEvent = event;
                return _textResponse('ok');
              },
            },
          },
        );

        await app.fetch(_request('/'), _context());

        expect(identical(capturedEvent.url, capturedEvent.url), isTrue);
      },
    );

    test(
      'event.query returns the same URLSearchParams instance on repeated access',
      () async {
        late Event capturedEvent;
        final app = Spry(
          routes: {
            '/': {
              null: (event) {
                capturedEvent = event;
                return _textResponse('ok');
              },
            },
          },
        );

        await app.fetch(_request('/?foo=bar'), _context());

        expect(identical(capturedEvent.query, capturedEvent.query), isTrue);
      },
    );
  });
}

Request _request(String path, {String method = 'GET'}) {
  return Request(
    Uri.parse('https://example.com$path'),
    RequestInit(method: HttpMethod.parse(method)),
  );
}

Response _textResponse(String value) {
  return Response(
    value,
    ResponseInit(headers: {'content-type': 'text/plain; charset=utf-8'}),
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
