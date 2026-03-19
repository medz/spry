import 'package:spry/spry.dart';
import 'package:spry/websocket.dart';

Request testRequest(String path, {String method = 'GET'}) {
  return Request(
    Uri.parse('https://example.com$path'),
    RequestInit(method: HttpMethod.parse(method)),
  );
}

RequestContext testRequestContext({
  required RuntimeCapabilities capabilities,
  WebSocketRequest? webSocket,
}) {
  return RequestContext(
    runtime: const RuntimeInfo(name: 'test', kind: 'server'),
    capabilities: capabilities,
    onWaitUntil: (_) {},
    webSocket: webSocket,
  );
}

final class FakeWebSocketRequest implements WebSocketRequest {
  FakeWebSocketRequest({
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
