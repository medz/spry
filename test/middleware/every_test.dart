import 'package:spry/app.dart';
import 'package:spry/middleware.dart';
import 'package:spry/osrv.dart';
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
