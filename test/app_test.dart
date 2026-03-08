import 'package:osrv/osrv.dart';
import 'package:spry/src/app.dart';
import 'package:spry/src/error_route.dart';
import 'package:spry/src/errors.dart';
import 'package:spry/src/middleware.dart';
import 'package:test/test.dart';

void main() {
  group('Spry.fetch', () {
    test('returns a text response from a string handler', () async {
      final app = Spry(
        routes: {
          '/': {null: (_) => Response.text('hello')},
        },
      );

      final response = await app.fetch(_request('/'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'hello');
      expect(response.headers.get('content-type'), contains('text/plain'));
    });

    test('injects route params into the event', () async {
      final app = Spry(
        routes: {
          '/users/:id': {
            'GET': (event) => Response.text(event.params.required('id')),
          },
        },
      );

      final response = await app.fetch(_request('/users/42'), _context());

      expect(response.status, 200);
      expect(await response.text(), '42');
    });

    test('uses fallback when no route matches', () async {
      final app = Spry(fallback: {null: (_) => Response.text('fallback')});

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
            path: '/*',
            handler: (error, stackTrace, event) {
              expect(error, isA<NotFoundError>());
              return Response.text('not-found');
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
            'GET': (_) {
              log.add('handler');
              return Response.text('ok');
            },
          },
        },
        middleware: [
          MiddlewareRoute(
            path: '/*',
            handler: (event, next) async {
              log.add('global before');
              final response = await next();
              log.add('global after');
              return response;
            },
          ),
          MiddlewareRoute(
            path: '/api/*',
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
          '/api/demo': {'GET': (_) => throw StateError('boom')},
        },
        errors: [
          ErrorRoute(
            path: '/*',
            handler: (error, stackTrace, event) => Response.text('root'),
          ),
          ErrorRoute(
            path: '/api/*',
            handler: (error, stackTrace, event) => Response.text('api'),
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
            '/api/demo': {'GET': (_) => throw StateError('boom')},
          },
          errors: [
            ErrorRoute(
              path: '/*',
              handler: (error, stackTrace, event) => Response.text('root'),
            ),
            ErrorRoute(
              path: '/api/*',
              handler: (error, stackTrace, event) => throw StateError('inner'),
            ),
          ],
        );

        final response = await app.fetch(_request('/api/demo'), _context());

        expect(response.status, 200);
        expect(await response.text(), 'root');
      },
    );
  });
}

Request _request(String path, {String method = 'GET'}) {
  return Request(Uri.parse('https://example.com$path'), method: method);
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
