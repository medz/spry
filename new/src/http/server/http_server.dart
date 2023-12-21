import 'dart:io';

import '../../application.dart';
import '../../responder/responder.dart';
import '../../server/server.dart';
import 'http_server_configuration.dart';

class HTTPServer implements Server {
  // Internal properties
  final Application _application;
  final Responder _responder;
  HttpServer? _server;

  /// The configuration of the server.
  final HTTPServerConfiguration configuration;

  HTTPServer({
    HTTPServerConfiguration? configuration,
    required Application application,
    required Responder responder,
  })  : _application = application,
        _responder = responder,
        configuration = configuration ?? HTTPServerConfiguration();

  @override
  Future<void> get onShutdown {}

  @override
  Future<void> shutdown() {
    // TODO: implement shutdown
    throw UnimplementedError();
  }

  @override
  Future<void> start(InternetAddress address) {
    // TODO: implement start
    throw UnimplementedError();
  }
}
