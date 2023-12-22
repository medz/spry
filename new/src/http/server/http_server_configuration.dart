import 'package:logging/logging.dart';
import 'package:webfetch/webfetch.dart';

import '../../server/server.dart';

class HTTPServerConfiguration {
  static const defaultHostname = '127.0.0.1';
  static const defaultPort = 4000;

  /// Address the server will bind to. Configuring an address using a hostname with a nil host or port will use the default hostname or port respectively.
  BindAddress address;

  HTTPServerConfiguration({
    BindAddress? address,
    String hostname = defaultHostname,
    int port = defaultPort,
    String? unixSocketPath,
  }) : address = address ??
            (unixSocketPath != null
                ? BindAddress.unix(unixSocketPath)
                : BindAddress.host(hostname, port));

  /// Returns the hostname of the server configuration.
  String get hostname {
    return switch (address) {
      HostAddress(hostname: final hostname) when hostname != null => hostname,
      _ => defaultHostname,
    };
  }

  /// Sets the hostname of the server configuration.
  set hostname(String hostname) => address = BindAddress.host(hostname, port);

  /// Returns or sets the port of the server configuration.
  int get port {
    return switch (address) {
      HostAddress(port: final port) when port != null => port,
      _ => defaultPort,
    };
  }

  /// Sets the port of the server configuration.
  set port(int port) => address = BindAddress.host(hostname, port);

  /// Listen backlog.
  int backlog = 0;

  /// Whether the [Server] should compress the content, if possible.
  ///
  /// If `true`, the server will compress the content if the client supports it.
  /// If `false`, the server will never compress the content.
  bool compression = false;

  /// Default response headers.
  ///
  /// If [Response] headers are not set, these headers will be used.
  Headers defaultResponseHeaders = Headers({
    'Powered-By': 'https://spry.fun',
    'Server': 'Spry',
  });

  /// HTTP server logger.
  Logger logger = Logger('spry.http.server');
}
