import 'dart:io';

import 'package:logging/logging.dart';
import 'package:webfetch/webfetch.dart';

class HTTPServerConfiguration {
  static const defaultHostname = '127.0.0.1';
  static const defaultPort = 4000;

  /// Address the server will bind to. Configuring an address using a hostname with a nil host or port will use the default hostname or port respectively.
  InternetAddress address;

  HTTPServerConfiguration({
    InternetAddress? address,
    String? hostname,
    this.port = defaultPort,
  }) : address = address ?? InternetAddress(hostname ?? defaultHostname);

  /// Returns the hostname of the server configuration.
  String get hostname => address.host;

  /// Sets the hostname of the server configuration.
  set hostname(String hostname) {
    address = InternetAddress(hostname, type: address.type);
  }

  /// Returns or sets the port of the server configuration.
  int port;

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
