import 'package:spry/app.dart';
import 'package:spry/middleware.dart';
import 'package:spry/osrv.dart';
import 'package:test/test.dart';

void main() {
  group('timing', () {
    test('adds a server-timing header when absent', () async {
      final app = Spry(
        routes: {
          '/': {
            HttpMethod.get: (_) async {
              await Future<void>.delayed(const Duration(milliseconds: 2));
              return Response('ok');
            },
          },
        },
        middleware: [MiddlewareRoute(path: '/**', handler: timing())],
      );

      final response = await app.fetch(_request('/'), _context());
      final headerValue = response.headers.get('server-timing');

      expect(headerValue, isNotNull);
      expect(headerValue, startsWith('app;dur='));
    });

    test('appends to an existing server-timing header', () async {
      final app = Spry(
        routes: {
          '/': {
            HttpMethod.get: (_) => Response(
              'ok',
              ResponseInit(headers: {'server-timing': 'db;dur=4.0'}),
            ),
          },
        },
        middleware: [MiddlewareRoute(path: '/**', handler: timing())],
      );

      final response = await app.fetch(_request('/'), _context());

      expect(response.headers.get('server-timing'), contains('db;dur=4.0'));
      expect(response.headers.get('server-timing'), contains('app;dur='));
    });

    test('uses a custom metric name', () async {
      final app = Spry(
        routes: {
          '/': {HttpMethod.get: (_) => Response('ok')},
        },
        middleware: [
          MiddlewareRoute(
            path: '/**',
            handler: timing(metricName: 'spry'),
          ),
        ],
      );

      final response = await app.fetch(_request('/'), _context());

      expect(response.headers.get('server-timing'), startsWith('spry;dur='));
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
