import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../server.dart';
import '_utils.dart';

extension type BunServer._(JSObject _) implements JSObject {
  external String get hostname;
  external int get port;
  external void stop([bool closeActiveConnections]);
}

extension type BunServe._(JSObject _) implements JSObject {
  external factory BunServe({
    String? hostname,
    int? port,
    bool? reusePort,
    JSFunction fetch,
  });
}

@JS('Bun')
extension type Bun._(JSAny _) {
  external static BunServer serve(BunServe serve);
}

class RuntimeServer extends Server {
  RuntimeServer(super.options) {
    Future<web.Response> handler(web.Request request) async {
      return fetch(request.toSpryRequest())
          .then((response) => response.toWebResponse());
    }

    runtime = Bun.serve(BunServe(
      fetch: handler.toJS,
      hostname: options.hostname,
      port: options.port,
      reusePort: options.reusePort,
    ));
  }

  late final Future<void> future;

  @override
  late final BunServer runtime;

  @override
  Future<void> ready() async {}

  @override
  Future<void> close({bool force = false}) async {
    runtime.stop(force);
  }
}
