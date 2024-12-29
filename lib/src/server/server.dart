import 'dart:async';

import '../http/request.dart';
import '../http/response.dart';

typedef ServerHandler = FutureOr<Response> Function(
    Request request, Server server);

class ServerOptions {
  const ServerOptions({
    required this.hostname,
    required this.port,
    required this.fetch,
    required this.reusePort,
  });

  final String hostname;
  final int port;
  final bool reusePort;
  final ServerHandler fetch;
}

abstract class Server {
  const Server(this.options);

  final ServerOptions options;
  dynamic get runtime;

  Future<Response> fetch(Request request) async {
    return await options.fetch(request, this);
  }

  Future<void> ready();
  Future<void> close({bool force = false});
}
