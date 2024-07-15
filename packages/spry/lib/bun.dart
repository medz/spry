@JS()
library spry.platform.bun;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'spry.dart';
import 'web.dart';
import 'websocket.dart';

const _kIsUpgradeWebSocket = #spry.bun.is_upgrade_websocket;
const _kBunServerInstance = #spry.bun.server;

extension SpryBun on Spry {
  // Server serve() {}
}

class BunPlatform extends WebPlatform
    with WebSocketPlatform<web.Request, web.Response> {
  @override
  String getClientAddress(Event event, web.Request request) {
    final server = event.locals.getOrNull<Server>(_kBunServerInstance);
    if (server == null) {
      return super.getClientAddress(event, request);
    }

    final socketAddress = server.requestIP(request);
    if (socketAddress == null) {
      return super.getClientAddress(event, request);
    }

    return '${socketAddress.address}:${socketAddress.port}';
  }

  @override
  FutureOr websocket(Event event, web.Request request, Hooks hooks) async {
    final server = event.locals.getOrNull<Server>(_kBunServerInstance);
    if (server == null) {
      return hooks.fallback(event);
    }

    final options = await hooks.onUpgrade(event);
    final upgradeOptions = BunUpgradeWebSocketOptions<_WebSocketData>(
      headers: options.headers.toWebHeaders(),
      data: _WebSocketData(event, hooks),
    );
    if (server.upgrade(request, upgradeOptions) != true) {
      return hooks.fallback(event);
    }

    event.locals.set(_kIsUpgradeWebSocket, true);

    return Response(null, status: 101);
  }
}

extension type Bun._(JSAny _) implements JSAny {
  external static Server serve<T extends JSAny>(Serve<T> params);
}

extension type Serve<T extends JSAny?>._(JSObject _) implements JSObject {
  // factory Serve({
  //   required JSPromise<web.Response?> Function(web.Request, Server) fetch,
  // }) {}
}

extension type Server._(JSObject _) implements JSObject {
  external void stop([bool closeActiveConnections]);
  external bool upgrade<T extends JSAny?>(web.Request request,
      [BunUpgradeWebSocketOptions<T> options]);
  external SocketAddress? requestIP(web.Request request);
}

extension type BunUpgradeWebSocketOptions<T extends JSAny?>._(JSObject _)
    implements JSObject {
  factory BunUpgradeWebSocketOptions({web.Headers? headers, T? data}) {
    final inner = JSObject();
    if (headers != null) inner['headers'] = headers;
    if (data != null) inner['data'] = data;

    return BunUpgradeWebSocketOptions<T>._(inner);
  }
}

extension type _WebSocketData._(JSObject _) implements JSObject {
  factory _WebSocketData(Event event, Hooks hooks) {
    final inner = JSObject()
      ..['event'] = event.toJSBox
      ..['hooks'] = hooks.toJSBox;

    return _WebSocketData._(inner);
  }

  Event get event {
    return getProperty<JSBoxedDartObject>('event'.toJS).toDart as Event;
  }

  Hooks get hooks {
    return getProperty<JSBoxedDartObject>('hooks'.toJS).toDart as Hooks;
  }
}

extension type SocketAddress._(JSObject _) implements JSObject {
  external String get address;
  external JSNumber get port;
  external String get family;
}

extension on Headers {
  web.Headers toWebHeaders() {
    final headers = web.Headers();

    for (final (name, value) in this) {
      headers.append(name, value);
    }

    return headers;
  }
}
