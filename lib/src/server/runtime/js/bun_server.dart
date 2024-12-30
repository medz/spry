import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../server.dart';
import '_utils.dart';

extension type SocketAddress._(JSObject _) implements JSObject {
  external String get address;
  external int get port;
  external String get family;
}

extension type BunServer._(JSObject _) implements JSObject {
  external String get hostname;
  external int get port;
  external web.URL get url;
  external void stop([bool closeActiveConnections]);
  external SocketAddress requestIP(web.Request request);
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

class RuntimeServer extends Server<BunServer, web.Request> {
  RuntimeServer(super.options) {
    JSPromise<web.Response> handler(web.Request request) {
      return fetch(request.toSpryRequest())
          .then((response) => response.toWebResponse())
          .toJS;
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

  @override
  String? get hostname => runtime.hostname;

  @override
  int? get port => runtime.port;

  @override
  String get url => runtime.url.toString();

  @override
  String? remoteAddress(web.Request request) {
    final addr = runtime.requestIP(request);
    final hostname = addr.family == 'IPv6' ? '[${addr.address}]' : addr.address;
    return '$hostname:${addr.port}';
  }
}
