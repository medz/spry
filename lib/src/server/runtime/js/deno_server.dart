import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../server.dart';
import '_utils.dart';

extension type ServeTcpOptions._(JSObject _) implements JSObject {
  external factory ServeTcpOptions({
    int? port,
    String? hostname,
    bool? reusePort,
    JSFunction? onListen,
  });
}

extension type Addr._(JSObject _) implements JSObject {
  external String get hostname;
  external int get port;
}

extension type DenoServer._(JSObject _) implements JSObject {
  external JSPromise shutdown();
  external Addr get addr;
}

extension type ServeHandlerInfo._(JSObject _) implements JSObject {
  external Addr get remoteAddr;
}

extension type Deno._(JSAny _) {
  external static DenoServer serve(ServeTcpOptions options, JSFunction handler);
}

extension on web.Request {
  external Addr remoteAddr;
}

class RuntimeServer extends Server<DenoServer, web.Request> {
  RuntimeServer(super.options) {
    final completer = Completer<void>();

    void ready() => completer.complete();
    JSPromise<web.Response> handler(
      web.Request request,
      ServeHandlerInfo info,
    ) {
      request.remoteAddr = info.remoteAddr;
      return fetch(request.toSpryRequest())
          .then((response) => response.toWebResponse())
          .toJS;
    }

    final denoServeOptions = ServeTcpOptions(
      hostname: options.hostname,
      port: options.port,
      reusePort: options.reusePort,
      onListen: ready.toJS,
    );

    future = completer.future;
    runtime = Deno.serve(denoServeOptions, handler.toJS);
  }

  late final Future<void> future;

  @override
  late final DenoServer runtime;

  @override
  Future<void> close({bool force = false}) async {
    await runtime.shutdown().toDart;
  }

  @override
  Future<void> ready() => future;

  @override
  String? get hostname => runtime.addr.hostname;

  @override
  int? get port => runtime.addr.port;

  @override
  String? remoteAddress(web.Request request) {
    final addr = request.remoteAddr.hostname.contains(':')
        ? '[${request.remoteAddr.hostname}]'
        : request.remoteAddr.hostname;
    return '$addr:${request.remoteAddr.port}';
  }
}
