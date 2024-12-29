import 'dart:async';

import '../http/request.dart';
import '../http/response.dart';

typedef ServerHandler = FutureOr<Response> Function(
    Request request, Server server);

class ServerOptions {
  const ServerOptions({
    this.hostname,
    this.port,
    required this.fetch,
    required this.reusePort,
  });

  final String? hostname;
  final int? port;
  final bool reusePort;
  final ServerHandler fetch;
}

abstract class Server<S, R> {
  const Server(this.options);

  final ServerOptions options;
  S get runtime;
  String? get hostname;
  int? get port;

  String? get url {
    if (hostname == null) {
      return null;
    }

    final addr = switch (hostname?.contains(':')) {
      true => '[$hostname]',
      false => hostname,
      _ => options.hostname,
    };
    if (port == null) {
      return addr;
    }

    return 'http://$addr:$port';
  }

  Future<Response> fetch(Request request) async {
    return await options.fetch(request, this);
  }

  Future<void> ready();
  Future<void> close({bool force = false});

  String? remoteAddress(R request);
}
