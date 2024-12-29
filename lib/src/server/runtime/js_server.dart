import 'dart:js_interop';
import 'dart:js_util' as js_utils show globalThis;

import '../../http/request.dart';
import '../../http/response.dart';
import '../server.dart';
import 'js/bun_server.dart' as bun;
import 'js/node_server.dart' as node;
import 'js/deno_server.dart' as deno;

extension type Versions._(JSObject _) implements JSObject {
  external String get node;
}

extension type NodeProcess._(JSObject _) implements JSObject {
  external Versions get versions;
}

extension type GlobalThis._(JSObject _) implements JSObject {
  // ignore: non_constant_identifier_names
  external JSObject? get Bun;
  // ignore: non_constant_identifier_names
  external JSObject? get Deno;
  external set self(GlobalThis _);
}

final GlobalThis globalThis = js_utils.globalThis as GlobalThis;

class RuntimeServer extends Server {
  RuntimeServer._(super.options, this.server);

  factory RuntimeServer(ServerOptions options) {
    late final Server server;
    if (globalThis.Bun.isTruthy.toDart) {
      server = bun.RuntimeServer(options);
    } else if (globalThis.Deno.isTruthy.toDart) {
      server = deno.RuntimeServer(options);
    } else {
      // Node does not define self, but Dart compiled to JS always operates on self.
      // This fixes the issue where Node cannot read self.
      globalThis.self = globalThis;
      server = node.RuntimeServer(options);
    }

    return RuntimeServer._(options, server);
  }

  final Server server;

  @override
  Future<void> ready() => server.ready();

  @override
  Future<void> close({bool force = false}) => server.close(force: force);

  @override
  Future<Response> fetch(Request request) => server.fetch(request);

  @override
  get runtime => server.runtime;

  @override
  String? get hostname => server.hostname;

  @override
  int? get port => server.port;

  @override
  String? remoteAddress(request) => server.remoteAddress(request);
}
