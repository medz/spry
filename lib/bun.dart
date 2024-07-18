import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'spry.dart';
import 'ws.dart';
import 'web.dart';

extension type UpgradeOptions._(JSObject _) implements JSObject {
  external web.Headers? headers;
  external JSAny? data;
}

extension type SocketAddress._(JSObject _) implements JSObject {
  external String get address;
  external JSNumber get port;
  external String get family;
}

extension type Server._(JSObject _) implements JSObject {
  external bool upgrade(web.Request request, [UpgradeOptions? options]);
  external SocketAddress? requestIP(web.Request request);
}

extension type Serve<T extends JSAny>._(JSObject _) implements JSObject {
  factory Serve({
    required Future<web.Response?> Function(web.Request, Server) fetch,
    WebSocketHandler? websocket,
  }) {
    JSPromise<web.Response?> handle(web.Request request, Server server) {
      return fetch(request, server).toJS;
    }

    final inner = JSObject()
      ..['fetch'] = handle.toJS
      ..['websocket'] = websocket;

    return Serve._(inner);
  }

  external int port;
  external String hostname;
  external WebSocketHandler? websocket;
  external JSPromise<web.Response?> fetch(web.Request request, Server server);
}

extension type ServerWebSocket._(JSObject _) implements JSObject {
  external JSAny? get data;
  external JSNumber get readyState;
  external JSString get remoteAddress;
  external JSNumber send(JSAny message, [bool? boolean]);
  external void close([JSNumber? code, JSString? reason]);
}

extension type WebSocketHandler._(JSObject _) implements JSObject {
  factory WebSocketHandler({
    required void Function(ServerWebSocket, JSAny) message,
    void Function(ServerWebSocket)? open,
    void Function(ServerWebSocket, [JSNumber?, JSString?])? close,
    void Function(ServerWebSocket, JSAny)? error,
  }) {
    final inner = JSObject()..['message'] = message.toJS;

    return WebSocketHandler._(inner);
  }
}

@JS('Bun')
extension type Bun._(JSAny _) implements JSAny {
  external static Server serve<T extends JSAny>(Serve<T> serve);
}

Serve toBunServe(Spry app) {
  return Serve(
    fetch: _createBunServeFetch(app),
    websocket: _createWebSocketHandler(),
  );
}

WebSocketHandler _createWebSocketHandler() {
  (Event, Hooks) resolve(JSAny? data) {
    return switch (data.dartify()) {
      (Event, Hooks) context => context,
      _ => throw createError('WebSocket context error'),
    };
  }

  final handler = WebSocketHandler(
    message: (ws, raw) {
      final message = switch (raw) {
        JSString value => Message.text(value.toDart),
        JSArrayBuffer buffer => Message.bytes(buffer.toDart.asUint8List()),
        JSUint8Array bytes => Message.bytes(bytes.toDart),
        _ => throw createError('WebSocket message is illegal'),
      };
      final (event, hooks) = resolve(ws.data);
      final peer = _BunPeer(event, ws);

      hooks.message(peer, message);
    },
  );

  return handler;
}

Future<web.Response?> Function(web.Request, Server) _createBunServeFetch(
    Spry app) {
  final handler = toHandler(app);

  return (request, server) async {
    final event = createWebEvent(app, request);
    final connectionInfo = server.requestIP(request);
    if (connectionInfo != null) {
      setClientAddress(
          event, '${connectionInfo.address}:${connectionInfo.port}');
    }

    bool upgraded = false;
    onUpgrade(event, (hooks) async {
      final headers = await hooks.upgrade(event);
      final options = UpgradeOptions._(JSObject())
        ..headers = switch (headers) {
          Headers headers => toWebHeaders(headers),
          _ => null,
        }
        ..data = (event, hooks).jsify();

      return upgraded = server.upgrade(request, options);
    });

    final response = await handler(event);
    return switch (upgraded) {
      true => null,
      _ => toWebResponse(response),
    };
  };
}

class _BunPeer implements Peer {
  const _BunPeer(this.event, this.websocket);

  final Event event;
  final ServerWebSocket websocket;

  @override
  String get extensions =>
      useRequest(event).headers.get('Sec-Websocket-Extensions') ?? '';

  @override
  String? get protocol => null;

  @override
  ReadyState get readyState => ReadyState(websocket.readyState.toDartInt);

  @override
  void remove(Object? key) => event.remove(key);

  @override
  T? get<T>(Object? key) => event.get<T>(key);

  @override
  void set<T>(Object? key, T value) => event.set<T>(key, value);

  @override
  void send(Message message, [bool? compress = false]) {
    final raw = switch (message.raw) {
      String value => value.toJS,
      _ => message.bytes().toJS,
    };

    websocket.send(raw, compress);
  }

  @override
  Future<void> close([int? code, String? reason]) async {
    websocket.close(code?.toJS, reason?.toJS);
  }
}
