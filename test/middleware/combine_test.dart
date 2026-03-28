import 'package:spry/app.dart';
import 'package:spry/middleware.dart';
import 'package:spry/osrv.dart';
import 'package:spry/src/event.dart';
import 'package:test/test.dart';

void main() {
  group('every', () {
    test('runs middleware in the provided order', () async {
      final log = <String>[];
      final app = Spry(
        routes: {
          '/': {
            HttpMethod.get: (_) {
              log.add('handler');
              return Response('ok');
            },
          },
        },
        middleware: [
          MiddlewareRoute(
            path: '/**',
            handler: every([
              (event, next) async {
                log.add('first before');
                final response = await next();
                log.add('first after');
                return response;
              },
              (event, next) async {
                log.add('second before');
                final response = await next();
                log.add('second after');
                return response;
              },
            ]),
          ),
        ],
      );

      final response = await app.fetch(_request('/'), _context());

      expect(response.status, 200);
      expect(log, [
        'first before',
        'second before',
        'handler',
        'second after',
        'first after',
      ]);
    });

    test('falls through to next when the list is empty', () async {
      final app = Spry(
        routes: {
          '/': {HttpMethod.get: (_) => Response('ok')},
        },
        middleware: [MiddlewareRoute(path: '/**', handler: every([]))],
      );

      final response = await app.fetch(_request('/'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'ok');
    });

    test('preserves order for non-list iterables', () async {
      final log = <String>[];
      final app = Spry(
        routes: {
          '/': {
            HttpMethod.get: (_) {
              log.add('handler');
              return Response('ok');
            },
          },
        },
        middleware: [
          MiddlewareRoute(
            path: '/**',
            handler: every(_iterableMiddleware(log)),
          ),
        ],
      );

      final response = await app.fetch(_request('/'), _context());

      expect(response.status, 200);
      expect(log, [
        'first before',
        'second before',
        'handler',
        'second after',
        'first after',
      ]);
    });

    test('stops when one middleware returns a response', () async {
      final log = <String>[];
      final app = Spry(
        routes: {
          '/': {
            HttpMethod.get: (_) {
              log.add('handler');
              return Response('ok');
            },
          },
        },
        middleware: [
          MiddlewareRoute(
            path: '/**',
            handler: every([
              (event, next) async {
                log.add('first');
                return Response('blocked');
              },
              (event, next) async {
                log.add('second');
                return next();
              },
            ]),
          ),
        ],
      );

      final response = await app.fetch(_request('/'), _context());

      expect(await response.text(), 'blocked');
      expect(log, ['first']);
    });
  });

  group('except', () {
    test('skips the wrapped middleware when the predicate matches', () async {
      final log = <String>[];
      final app = Spry(
        routes: {
          '/healthz': {
            HttpMethod.get: (_) {
              log.add('handler');
              return Response('ok');
            },
          },
        },
        middleware: [
          MiddlewareRoute(
            path: '/**',
            handler: except((event, next) async {
              log.add('wrapped');
              return next();
            }, (event) => event.pathname == '/healthz'),
          ),
        ],
      );

      final response = await app.fetch(_request('/healthz'), _context());

      expect(response.status, 200);
      expect(log, ['handler']);
    });

    test(
      'runs the wrapped middleware when the predicate does not match',
      () async {
        final log = <String>[];
        final app = Spry(
          routes: {
            '/users': {
              HttpMethod.get: (_) {
                log.add('handler');
                return Response('ok');
              },
            },
          },
          middleware: [
            MiddlewareRoute(
              path: '/**',
              handler: except((event, next) async {
                log.add('wrapped before');
                final response = await next();
                log.add('wrapped after');
                return response;
              }, (event) => event.pathname == '/healthz'),
            ),
          ],
        );

        final response = await app.fetch(_request('/users'), _context());

        expect(response.status, 200);
        expect(log, ['wrapped before', 'handler', 'wrapped after']);
      },
    );

    test(
      'still falls through when the wrapped middleware is skipped',
      () async {
        final app = Spry(
          routes: {
            '/': {HttpMethod.get: (_) => Response('ok')},
          },
          middleware: [
            MiddlewareRoute(
              path: '/**',
              handler: except(
                (event, next) => Response('blocked'),
                (_) => true,
              ),
            ),
          ],
        );

        final response = await app.fetch(_request('/'), _context());

        expect(response.status, 200);
        expect(await response.text(), 'ok');
      },
    );
  });

  group('some', () {
    test('rejects empty middleware', () {
      expect(() => some([]), throwsArgumentError);
    });

    test('returns the first successful middleware result', () async {
      final log = <String>[];
      final middleware = some([
        (event, next) async {
          log.add('first');
          throw StateError('first failed');
        },
        (event, next) async {
          log.add('second before');
          final response = await next();
          log.add('second after');
          return response;
        },
        (event, next) async {
          log.add('third');
          return Response('third');
        },
      ]);

      final response = await middleware(_event('/'), () async {
        log.add('next');
        return Response('ok');
      });

      expect(response.status, 200);
      expect(await response.text(), 'ok');
      expect(log, ['first', 'second before', 'next', 'second after']);
    });

    test('reuses the same downstream next result across candidates', () async {
      var nextCalls = 0;
      final middleware = some([
        (event, next) async {
          await next();
          throw StateError('first failed');
        },
        (event, next) async {
          await next();
          throw ArgumentError('second failed');
        },
        (event, next) => next(),
      ]);

      final response = await middleware(_event('/'), () async {
        nextCalls += 1;
        return Response('ok');
      });

      expect(nextCalls, 1);
      expect(await response.text(), 'ok');
    });

    test('throws the last error when every middleware fails', () async {
      final middleware = some([
        (event, next) async => throw StateError('first failed'),
        (event, next) async => throw ArgumentError('second failed'),
      ]);

      await expectLater(
        middleware(_event('/'), () async => Response('ok')),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

Request _request(
  String path, {
  String method = 'GET',
  Map<String, String>? headers,
}) {
  return Request(
    Uri.parse('https://example.com$path'),
    RequestInit(method: HttpMethod.parse(method), headers: headers),
  );
}

Event _event(String path) {
  return Event(
    app: Spry(
      routes: {
        '/': {HttpMethod.get: (_) => Response('ok')},
      },
    ),
    request: _request(path),
    context: _context(),
  );
}

Iterable<Middleware> _iterableMiddleware(List<String> log) sync* {
  yield (event, next) async {
    log.add('first before');
    final response = await next();
    log.add('first after');
    return response;
  };

  yield (event, next) async {
    log.add('second before');
    final response = await next();
    log.add('second after');
    return response;
  };
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
