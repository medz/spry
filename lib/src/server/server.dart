import 'dart:async';

import '../http/request.dart';
import '../http/response.dart';

/// Spry server handler.
typedef ServerHandler = FutureOr<Response> Function(
    Request request, Server server);

/// Spry server options.
class ServerOptions {
  const ServerOptions({
    this.hostname,
    this.port,
    required this.fetch,
    required this.reusePort,
  });

  /// The server listen hostname.
  final String? hostname;

  /// The server listen port.
  final int? port;

  /// Do you allow shared ports.
  final bool reusePort;

  /// The processing program of the server after receiving the request.
  final ServerHandler fetch;
}

/// The spry server.
abstract class Server<S, R> {
  /// Creates a new server.
  const Server(this.options);

  /// Returns the server options.
  final ServerOptions options;

  /// Returns the server runtime-platform server instance.
  S get runtime;

  /// Returns resolved listen hostname.
  String? get hostname;

  /// Returns resolved listen port.
  int? get port;

  /// Returns listen url.
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

  /// The server fetch.
  Future<Response> fetch(Request request) async {
    return await options.fetch(request, this);
  }

  /// Wait for the server to be ready.
  Future<void> ready();

  /// Close the server.
  Future<void> close({bool force = false});

  /// Resolve a request remote address.
  String? remoteAddress(R request);
}
