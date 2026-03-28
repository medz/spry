import 'package:spry/app.dart';
import 'package:spry/middleware.dart';
import 'package:spry/osrv.dart';
import 'package:test/test.dart';

void main() {
  group('requestId', () {
    test(
      'generates an id, stores it in locals, and fills the response header',
      () async {
        late String? capturedId;
        final app = Spry(
          routes: {
            '/': {
              HttpMethod.get: (event) {
                capturedId = event.locals.get<String>(#requestId);
                return Response(capturedId ?? 'missing');
              },
            },
          },
          middleware: [MiddlewareRoute(path: '/**', handler: requestId())],
        );

        final response = await app.fetch(_request('/'), _context());
        final headerValue = response.headers.get('x-request-id');

        expect(capturedId, isNotNull);
        expect(capturedId, isNotEmpty);
        expect(headerValue, capturedId);
        expect(await response.text(), capturedId);
      },
    );

    test('reuses the incoming request id by default', () async {
      late String? capturedId;
      final app = Spry(
        routes: {
          '/': {
            HttpMethod.get: (event) {
              capturedId = event.locals.get<String>(#requestId);
              return Response('ok');
            },
          },
        },
        middleware: [MiddlewareRoute(path: '/**', handler: requestId())],
      );

      final response = await app.fetch(
        _request('/', headers: {'x-request-id': 'incoming-id'}),
        _context(),
      );

      expect(capturedId, 'incoming-id');
      expect(response.headers.get('x-request-id'), 'incoming-id');
    });

    test(
      'ignores the incoming request id when trustIncoming is false',
      () async {
        late String? capturedId;
        final app = Spry(
          routes: {
            '/': {
              HttpMethod.get: (event) {
                capturedId = event.locals.get<String>(#requestId);
                return Response(capturedId ?? 'missing');
              },
            },
          },
          middleware: [
            MiddlewareRoute(
              path: '/**',
              handler: requestId(trustIncoming: false),
            ),
          ],
        );

        final response = await app.fetch(
          _request('/', headers: {'x-request-id': 'incoming-id'}),
          _context(),
        );

        expect(capturedId, isNotNull);
        expect(capturedId, isNot('incoming-id'));
        expect(response.headers.get('x-request-id'), capturedId);
      },
    );

    test('does not override a response header that is already set', () async {
      late String? capturedId;
      final app = Spry(
        routes: {
          '/': {
            HttpMethod.get: (event) {
              capturedId = event.locals.get<String>(#requestId);
              return Response(
                capturedId ?? 'missing',
                ResponseInit(headers: {'x-request-id': 'handler-id'}),
              );
            },
          },
        },
        middleware: [MiddlewareRoute(path: '/**', handler: requestId())],
      );

      final response = await app.fetch(_request('/'), _context());

      expect(capturedId, isNotNull);
      expect(capturedId, isNot('handler-id'));
      expect(response.headers.get('x-request-id'), 'handler-id');
      expect(await response.text(), capturedId);
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
