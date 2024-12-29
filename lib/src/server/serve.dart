import 'runtime/runtime.dart';
import 'server.dart';

/// Creates a Corss-Server.
///
/// Example:
/// ```dart
/// final server = serve(
///   fetch: (request, _) => Response.fromString('Hello'),
/// );
/// await server.ready();
/// ```
Server serve({
  String? hostname,
  int? port,
  bool? reusePort,
  required ServerHandler fetch,
}) {
  final options = ServerOptions(
    hostname: hostname ?? 'localhost',
    port: port ?? 3000,
    reusePort: reusePort ?? true,
    fetch: fetch,
  );

  return RuntimeServer(options);
}
