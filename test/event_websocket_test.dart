import 'package:spry/spry.dart';
import 'package:spry/websocket.dart';
import 'package:test/test.dart';

void main() {
  group('Event.ws', () {
    test('reports unsupported when runtime websocket capability is false', () {
      final event = _event(
        capabilities: const RuntimeCapabilities(
          streaming: true,
          websocket: false,
          fileSystem: false,
          backgroundTask: true,
          rawTcp: false,
          nodeCompat: false,
        ),
      );

      expect(event.ws.isSupported, isFalse);
      expect(event.ws.isUpgradeRequest, isFalse);
      expect(event.ws.requestedProtocols, isEmpty);
    });

    test('exposes websocket upgrade metadata from the request context', () {
      final event = _event(
        capabilities: const RuntimeCapabilities(
          streaming: true,
          websocket: true,
          fileSystem: false,
          backgroundTask: true,
          rawTcp: false,
          nodeCompat: false,
        ),
        webSocket: _FakeWebSocketRequest(
          isUpgradeRequest: true,
          requestedProtocols: const ['chat', 'superchat'],
        ),
      );

      expect(event.ws.isSupported, isTrue);
      expect(event.ws.isUpgradeRequest, isTrue);
      expect(event.ws.requestedProtocols, ['chat', 'superchat']);
    });

    test(
      'throws 501 when upgrading on a runtime without websocket support',
      () {
        final event = _event(
          capabilities: const RuntimeCapabilities(
            streaming: true,
            websocket: false,
            fileSystem: false,
            backgroundTask: true,
            rawTcp: false,
            nodeCompat: false,
          ),
        );

        expect(
          () => event.ws.upgrade((ws) async {}),
          throwsA(
            isA<HTTPError>()
                .having((error) => error.status, 'status', 501)
                .having(
                  (error) => error.body,
                  'body',
                  'WebSocket is not supported by this runtime.',
                ),
          ),
        );
      },
    );

    test('throws 426 when upgrading a non-websocket request', () {
      final event = _event(
        capabilities: const RuntimeCapabilities(
          streaming: true,
          websocket: true,
          fileSystem: false,
          backgroundTask: true,
          rawTcp: false,
          nodeCompat: false,
        ),
        webSocket: _FakeWebSocketRequest(
          isUpgradeRequest: false,
          requestedProtocols: const ['chat'],
        ),
      );

      expect(
        () => event.ws.upgrade((ws) async {}),
        throwsA(
          isA<HTTPError>()
              .having((error) => error.status, 'status', 426)
              .having((error) => error.body, 'body', 'Upgrade Required'),
        ),
      );
    });

    test('delegates upgrades to the runtime websocket request', () {
      final response = Response('ok');
      final webSocket = _FakeWebSocketRequest(
        isUpgradeRequest: true,
        requestedProtocols: const ['chat'],
        response: response,
      );
      final event = _event(
        capabilities: const RuntimeCapabilities(
          streaming: true,
          websocket: true,
          fileSystem: false,
          backgroundTask: true,
          rawTcp: false,
          nodeCompat: false,
        ),
        webSocket: webSocket,
      );

      final result = event.ws.upgrade((ws) async {}, protocol: 'chat');

      expect(result, same(response));
      expect(webSocket.acceptCallCount, 1);
      expect(webSocket.acceptedProtocol, 'chat');
      expect(webSocket.acceptedHandler, isNotNull);
    });
  });
}

Event _event({
  required RuntimeCapabilities capabilities,
  WebSocketRequest? webSocket,
}) {
  return Event(
    app: Spry(),
    request: Request('https://example.com/chat'),
    context: RequestContext(
      runtime: const RuntimeInfo(name: 'test', kind: 'server'),
      capabilities: capabilities,
      onWaitUntil: (_) {},
      webSocket: webSocket,
    ),
  );
}

final class _FakeWebSocketRequest implements WebSocketRequest {
  _FakeWebSocketRequest({
    required this.isUpgradeRequest,
    required this.requestedProtocols,
    Response? response,
  }) : _response = response ?? Response('accepted');

  @override
  final bool isUpgradeRequest;

  @override
  final List<String> requestedProtocols;

  final Response _response;
  int acceptCallCount = 0;
  String? acceptedProtocol;
  WebSocketHandler? acceptedHandler;

  @override
  Response accept(WebSocketHandler handler, {String? protocol}) {
    acceptCallCount += 1;
    acceptedProtocol = protocol;
    acceptedHandler = handler;
    return _response;
  }
}
