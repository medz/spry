import 'dart:io';

/// Spry test kit
Future<HttpServer> startServer(
  void Function(HttpRequest request) action,
) async {
  final server =
      await HttpServer.bind(InternetAddress.anyIPv4, 0, shared: true);
  server.listen(action);

  return server;
}

/// Create a [Uri] from a [HttpServer]
Uri serverUri(HttpServer server) =>
    Uri.http('${server.address.host}:${server.port}', '/');
