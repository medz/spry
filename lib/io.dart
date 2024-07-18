import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'spry.dart';
import 'ws.dart';

Future<void> Function(HttpRequest request) toIOHandler(Spry app) {
  final handler = toHandler(app);

  return (httpRequest) async {
    final spryRequest = Request(
      method: httpRequest.method,
      uri: httpRequest.requestedUri,
      headers: _createSpryHeaders(httpRequest.headers),
      body: httpRequest,
    );
    final event = createEvent(app, spryRequest);
    final httpResponse = httpRequest.response;
    final websocketUpgraded = _handleUpgrade(httpRequest, event);
    final spryResponse = await handler(event);

    if (await websocketUpgraded) return;

    httpResponse.statusCode = spryResponse.status;
    httpResponse.reasonPhrase = spryResponse.statusText;
    _writeSpryHeaders(httpResponse, spryResponse.headers);

    if (spryResponse.body != null) {
      await httpResponse.addStream(spryResponse.body!);
    }

    await httpResponse.close();
  };
}

Future<bool> _handleUpgrade(HttpRequest request, Event event) {
  final completer = Completer<bool>.sync();

  onUpgrade(event, (hooks) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      completer.complete(false);
      return false;
    }

    _writeSpryHeaders(request.response, await hooks.upgrade(event));
    final websocket = await WebSocketTransformer.upgrade(request);
    final peer = _IOPeer(event, websocket);

    await hooks.open(peer);
    websocket.listen(
      (raw) async {
        final message = switch (raw) {
          String text => Message.text(text),
          Uint8List bytes => Message.bytes(bytes),
          List<int> bytes => Message.bytes(Uint8List.fromList(bytes)),
          _ => throw createError('WebSocket message is illegal'),
        };

        await hooks.message(peer, message);
      },
      onDone: () async {
        await hooks.close(peer, websocket.closeCode, websocket.closeReason);
        await request.response.close();
      },
      onError: (error) async => hooks.error(peer, error),
    );

    completer.complete(true);
    return true;
  });

  return completer.future;
}

Headers _createSpryHeaders(HttpHeaders httpHeaders) {
  final inner = Headers();
  httpHeaders.forEach((name, values) {
    for (final value in values) {
      inner.add(name, value);
    }
  });

  return inner;
}

void _writeSpryHeaders(HttpResponse response, Headers? headers) {
  if (headers == null || headers.isEmpty) {
    return;
  }

  for (final (name, value) in headers) {
    response.headers.add(name, value, preserveHeaderCase: true);
  }
}

class _IOPeer implements Peer {
  const _IOPeer(this.event, this.websocket);

  final Event event;
  final WebSocket websocket;

  @override
  String get extensions => websocket.extensions;

  @override
  String? get protocol => websocket.protocol;

  @override
  ReadyState get readyState => ReadyState(websocket.readyState);

  @override
  void send(Message message) => websocket.add(message.raw);

  @override
  Future<void> close([int? code, String? reason]) async {
    await websocket.close(code, reason);
  }

  @override
  T? get<T>(Object? key) => event.get<T>(key);

  @override
  void set<T>(Object? key, T value) => event.set<T>(key, value);

  @override
  void remove(Object? key) => event.remove(key);
}
