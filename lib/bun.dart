import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'spry.dart';
import 'ws.dart';
import 'web.dart';

/// The Bun upgrade to WebSocket options.
extension type UpgradeOptions._(JSObject _) implements JSObject {
  /// Upgrade sent headers.
  external web.Headers? headers;

  /// Contextual [data] can be attached to a new WebSocket.
  external JSAny? data;
}

/// Bun socket address.
extension type SocketAddress._(JSObject _) implements JSObject {
  /// address, E.g: `127.0.0.1`
  external String get address;

  /// Connection port.
  external JSNumber get port;

  /// Address type, E.g: `ipv4`
  external String get family;
}

/// The Bun server
extension type Server._(JSObject _) implements JSObject {
  /// Upgrade a request to websocket.
  external bool upgrade(web.Request request, [UpgradeOptions? options]);

  /// Gets the request client socket address.
  external SocketAddress? requestIP(web.Request request);
}

/// Bun serve.
extension type Serve._(JSObject _) implements JSObject {
  /// Creates a new Bun serve.
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

  /// Gets/Set a serve port.
  external int port;

  /// Gets/Set a serve hostname, Default is `0.0.0.0`.
  external String hostname;

  /// Gets/Set a serve websocket handler.
  external WebSocketHandler? websocket;

  /// The serve on request call fn.
  external JSPromise<web.Response?> fetch(web.Request request, Server server);
}

/// Bun serevr websocket.
extension type ServerWebSocket._(JSObject _) implements JSObject {
  /// The upgrade contextual data.
  external JSAny? get data;

  /// The websocket ready state.
  external JSNumber get readyState;

  /// Send a message to client.
  external JSNumber send(JSAny message, [bool? boolean]);

  /// Close websocket.
  external void close([JSNumber? code, JSString? reason]);
}

/// Bun websocket handler.
extension type WebSocketHandler._(JSObject _) implements JSObject {
  /// Creates a new websocket handler.
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

/// Global Bun module.
@JS('Bun')
extension type Bun._(JSAny _) implements JSAny {
  /// Creates a bun server for [serve].
  external static Server serve(Serve serve);
}

/// Create a Bun serve object using Spry application.
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
      event.request.headers.get('Sec-Websocket-Extensions') ?? '';

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

  @override
  Spry get app => event.app;

  @override
  get raw => event.raw;

  @override
  Request get request => event.request;
}
