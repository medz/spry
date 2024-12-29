import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../../http/response.dart';
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
  RuntimeServer(super.options);

  @override
  late final BunServer runtime;

  JSPromise<web.Response> handler(web.Request request) {
    final response = fetch(request.toSpryRequest());
    final future = Future.sync(() async {
      final Response(:toWebResponse) = await response;
      return toWebResponse();
    });

    return future.toJS;
  }

  @override
  Future<void> ready() async {
    final serve = BunServe(
      fetch: handler.toJS,
      hostname: options.hostname,
      port: options.port,
      reusePort: options.reusePort,
    );
    runtime = Bun.serve(serve);
  }

  @override
  Future<void> close({bool force = false}) async {
    runtime.stop(force);
  }
}
