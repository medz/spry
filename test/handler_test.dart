import 'package:spry/app.dart';
import 'package:spry/osrv.dart';
import 'package:spry/spry.dart' show Event;
import 'package:test/test.dart';

void main() {
  group('defineHandler', () {
    test(
      'returns the original handler when no local behavior is configured',
      () {
        Response base(Event event) => _textResponse('ok');

        final defined = defineHandler(base);

        expect(identical(defined, base), isTrue);
      },
    );

    test('runs local middleware around only the wrapped handler', () async {
      final log = <String>[];
      final app = Spry(
        routes: {
          '/demo': {
            HttpMethod.get: defineHandler(
              (event) {
                log.add('handler');
                return _textResponse('ok');
              },
              middleware: [
                (event, next) async {
                  log.add('local before');
                  final response = await next();
                  log.add('local after');
                  return response;
                },
              ],
            ),
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
        ],
      );

      final response = await app.fetch(_request('/demo'), _context());

      expect(response.status, 200);
      expect(log, [
        'global before',
        'local before',
        'handler',
        'local after',
        'global after',
      ]);
    });

    test(
      'handles errors from the local middleware chain with local onError',
      () async {
        final outerErrors = <String>[];
        final app = Spry(
          routes: {
            '/demo': {
              HttpMethod.get: defineHandler(
                (event) => _textResponse('ok'),
                middleware: [
                  (event, next) async {
                    throw StateError('boom');
                  },
                ],
                onError: (error, stackTrace, event) {
                  return _textResponse('local');
                },
              ),
            },
          },
          errors: [
            ErrorRoute(
              path: '/**',
              handler: (error, stackTrace, event) {
                outerErrors.add('outer');
                return _textResponse('outer');
              },
            ),
          ],
        );

        final response = await app.fetch(_request('/demo'), _context());

        expect(response.status, 200);
        expect(await response.text(), 'local');
        expect(outerErrors, isEmpty);
      },
    );

    test('rethrows from local onError into the outer error pipeline', () async {
      final app = Spry(
        routes: {
          '/demo': {
            HttpMethod.get: defineHandler(
              (event) => throw StateError('boom'),
              onError: (error, stackTrace, event) {
                throw const HTTPError(418, body: 'teapot');
              },
            ),
          },
        },
        errors: [
          ErrorRoute(
            path: '/**',
            handler: (error, stackTrace, event) {
              expect(error, isA<HTTPError>());
              return _textResponse('outer');
            },
          ),
        ],
      );

      final response = await app.fetch(_request('/demo'), _context());

      expect(response.status, 200);
      expect(await response.text(), 'outer');
    });
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
