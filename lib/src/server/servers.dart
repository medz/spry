import 'package:logging/logging.dart';
import 'package:webfetch/webfetch.dart';

import '../core/core.dart';
import '../application.dart';
import 'bind_address.dart';
import 'server.dart';

class Servers {
  static const defaultHostname = 'localhost';
  static const defaultPort = 4000;

  final Logger _logger = Logger('spry.server');
  final Application _application;
  Server Function(Application application)? _factory;

  Servers(Application application) : _application = application;

  /// Returns the current server.
  Server get current {
    if (_factory == null) {
      throw StateError(
          'No server configured, configure with app.servers.use(...)');
    }

    final existing = _application.container.get<Server>();
    if (existing != null) return existing;

    final server = _factory!(_application);
    _application.container.set(server);

    return server;
  }

  /// Use a new server.
  void use(Server Function(Application application) factory) {
    if (_application.running != null) {
      _logger.severe('Cannot use server while application is running.');
      return;
    }

    _factory = factory;
    _application.container.remove<Server>();
  }

  /// Returns or sets default response headers.
  ///
  /// The default headers are added to all responses.
  ///
  /// **NOTE**: If you use another server, whether to add default headers to
  /// the Response depends on the implementation of the server.
  final Headers headers = Headers({
    "x-powered-by": "Spry framework (https://spry.fun)",
    'x-spry-version': Application.version,
  });

  /// Returns or sets server listening address.
  BindAddress address = BindAddress.host(defaultHostname, defaultPort);

  /// Returns or sets server listening hostname.
  String get hostname {
    return switch (address) {
      HostAddress(hostname: final hostname) => hostname ?? defaultHostname,
      _ => defaultHostname,
    };
  }

  /// Sets server listening hostname.
  set hostname(String hostname) {
    address = HostAddress(hostname, port);
  }

  /// Returns or sets server listening port.
  int get port {
    return switch (address) {
      HostAddress(port: final port) => port ?? defaultPort,
      _ => defaultPort,
    };
  }

  /// Sets server listening port.
  set port(int port) {
    address = HostAddress(hostname, port);
  }

  /// Whether the [Server] should compress the content, if possible.
  ///
  /// The content can only be compressed when the response is using
  /// chunked Transfer-Encoding and the incoming request has `gzip`
  /// as an accepted encoding in the Accept-Encoding header.
  ///
  /// The default value is `false` (compression disabled).
  /// To enable, set `autoCompress` to `true`.
  bool autoCompress = false;

  /// Gets or sets the timeout used for idle keep-alive connections. If no
  /// further request is seen within [idleTimeout] after the previous request was
  /// completed, the connection is dropped.
  ///
  /// Default is 120 seconds.
  ///
  /// Note that it may take up to `2 * idleTimeout` before a idle connection is
  /// aborted.
  ///
  /// To disable, set [idleTimeout] to `null`.
  Duration? idleTimeout = const Duration(seconds: 120);

  int backlog = 0;
  bool onlyIPv6 = false;
  bool shared = false;
}
