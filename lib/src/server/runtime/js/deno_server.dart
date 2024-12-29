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

extension type DenoServer._(JSObject _) implements JSObject {
  external Future<void> shutdown();
}

extension type Deno._(JSAny _) {
  external static DenoServer serve(ServeTcpOptions options, JSFunction handler);
}

class RuntimeServer extends Server {
  RuntimeServer(super.options) {
    final completer = Completer<void>();

    void ready() => completer.complete();
    Future<web.Response> handler(web.Request request) async {
      return await fetch(request.toSpryRequest())
          .then((response) => response.toWebResponse());
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
    await runtime.shutdown();
  }

  @override
  Future<void> ready() => future;
}
