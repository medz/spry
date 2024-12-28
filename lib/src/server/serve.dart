import 'runtime/runtime.dart';
import 'server.dart';

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
