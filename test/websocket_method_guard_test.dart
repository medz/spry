import 'package:spry/spry.dart';
import 'package:test/test.dart';

import 'support/websocket_test_support.dart';

void main() {
  group('websocket method guard', () {
    test(
      'HEAD routed through a GET websocket handler is rejected as 405',
      () async {
        final app = Spry(
          routes: {
            '/chat': {
              HttpMethod.get: (event) => event.ws.upgrade((ws) async {}),
            },
          },
        );

        final response = await app.fetch(
          testRequest('/chat', method: 'HEAD'),
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
              requestedProtocols: const <String>[],
            ),
          ),
        );

        expect(response.status, 405);
        expect(response.headers.get('allow'), 'GET');
      },
    );
  });
}
