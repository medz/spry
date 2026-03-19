import 'package:spry/spry.dart';
import 'package:test/test.dart';

import 'support/websocket_test_support.dart';

void main() {
  group('websocket semantics', () {
    test(
      'middleware wraps the websocket handshake like a normal request',
      () async {
        final log = <String>[];
        final webSocket = FakeWebSocketRequest(
          isUpgradeRequest: true,
          requestedProtocols: const ['chat'],
          response: Response('accepted'),
        );
        final app = Spry(
          routes: {
            '/chat': {
              HttpMethod.get: (event) {
                log.add('handler');
                return event.ws.upgrade((ws) async {});
              },
            },
          },
          middleware: [
            MiddlewareRoute(
              path: '/**',
              handler: (event, next) async {
                log.add('before');
                final response = await next();
                log.add('after');
                return response;
              },
            ),
          ],
        );

        final response = await app.fetch(
          testRequest('/chat'),
          testRequestContext(
            capabilities: const RuntimeCapabilities(
              streaming: true,
              websocket: true,
              fileSystem: false,
              backgroundTask: true,
              rawTcp: false,
              nodeCompat: false,
            ),
            webSocket: webSocket,
          ),
        );

        expect(response.status, 200);
        expect(log, ['before', 'handler', 'after']);
        expect(webSocket.acceptCallCount, 1);
      },
    );

    test(
      'handshake-time upgrade errors still flow through scoped error handlers',
      () async {
        final app = Spry(
          routes: {
            '/chat': {
              HttpMethod.get: (event) => event.ws.upgrade((ws) async {}),
            },
          },
          errors: [
            ErrorRoute(
              path: '/**',
              handler: (error, stackTrace, event) {
                expect(error, isA<HTTPError>());
                expect((error as HTTPError).status, 426);
                return Response('handled');
              },
            ),
          ],
        );

        final response = await app.fetch(
          testRequest('/chat'),
          testRequestContext(
            capabilities: const RuntimeCapabilities(
              streaming: true,
              websocket: true,
              fileSystem: false,
              backgroundTask: true,
              rawTcp: false,
              nodeCompat: false,
            ),
            webSocket: FakeWebSocketRequest(
              isUpgradeRequest: false,
              requestedProtocols: const ['chat'],
            ),
          ),
        );

        expect(response.status, 200);
        expect(await response.text(), 'handled');
      },
    );

    test('fallback can still accept a websocket upgrade request', () async {
      final webSocket = FakeWebSocketRequest(
        isUpgradeRequest: true,
        requestedProtocols: const ['chat'],
        response: Response('accepted'),
      );
      final app = Spry(
        fallback: {null: (event) => event.ws.upgrade((ws) async {})},
      );

      final response = await app.fetch(
        testRequest('/missing'),
        testRequestContext(
          capabilities: const RuntimeCapabilities(
            streaming: true,
            websocket: true,
            fileSystem: false,
            backgroundTask: true,
            rawTcp: false,
            nodeCompat: false,
          ),
          webSocket: webSocket,
        ),
      );

      expect(response.status, 200);
      expect(webSocket.acceptCallCount, 1);
    });

    test(
      'missing websocket route without fallback remains a normal 404',
      () async {
        final app = Spry();

        final response = await app.fetch(
          testRequest('/missing'),
          testRequestContext(
            capabilities: const RuntimeCapabilities(
              streaming: true,
              websocket: true,
              fileSystem: false,
              backgroundTask: true,
              rawTcp: false,
              nodeCompat: false,
            ),
            webSocket: FakeWebSocketRequest(
              isUpgradeRequest: true,
              requestedProtocols: const ['chat'],
            ),
          ),
        );

        expect(response.status, 404);
      },
    );
  });
}
