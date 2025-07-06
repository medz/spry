import 'dart:async';

import 'package:oxy/oxy.dart';

import '_internal/request_utils.dart';
import 'platform.dart' if (dart.library.js_interop) 'platform.js.dart' as inner;
import 'handler.dart';
import 'server.dart';

Server<Platform> serve<Platform extends inner.Platform>({
  required Platform platform,
  required ServerHandler fetch,
  String? hostname,
  int? port,
  bool reusePort = false,
  bool manual = false,
  bool silent = false,
  inner.TtlOptions? ttl,
}) {
  final factory = manual ? _ManualServer<Platform>.new : _Server<Platform>.new;
  final server = factory(
    platform: platform,
    handler: fetch,
    hostname: hostname,
    port: port,
    reusePort: reusePort,
    ttl: ttl,
  );

  if (!manual) {
    platform.serve(
      fetch: server.fetch,
      hostname: hostname,
      port: port,
      reusePort: reusePort,
      ttl: ttl,
    );
  }

  return server;
}

class _Server<Platform extends inner.Platform> implements Server<Platform> {
  const _Server({required this.platform, required this.handler});

  final ServerHandler<Platform> handler;

  @override
  final Platform platform;

  @override
  String? get url => platform.url;

  @override
  Future<Server<Platform>> ready() {
    return Future.sync(platform.ready).then((_) => this);
  }

  @override
  Future<void> close([bool force = false]) {
    return platform.close(force);
  }

  @override
  Future<Response> fetch(Request request) async {
    final serverRequest = createServerRequest(platform, request);
    return handler(serverRequest);
  }
}

class _ManualServer<Platform extends inner.Platform> extends _Server<Platform> {
  _ManualServer({
    required super.platform,
    required super.handler,
    required this.hostname,
    required this.port,
    required this.reusePort,
    this.ttl,
  });

  final String hostname;
  final int port;
  final bool reusePort;
  final inner.TtlOptions? ttl;

  Future<Server<Platform>>? readyFuture;

  @override
  Future<Server<Platform>> ready() async {
    return readyFuture ??= Future.sync(() {
      platform.serve(
        fetch: this.fetch,
        hostname: hostname,
        port: port,
        reusePort: reusePort,
        ttl: ttl,
      );
      return super.ready();
    });
  }
}
