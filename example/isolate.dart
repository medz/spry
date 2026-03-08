import 'dart:io';
import 'dart:isolate';

import 'package:spry/app.dart';
import 'package:spry/server.dart';

Future<void> runServer([_]) async {
  final app = Spry(
    routes: {
      '/': {HttpMethod.get: (_) => null},
      '/user': {HttpMethod.post: (_) => null},
      '/user/:name': {HttpMethod.get: (event) => event.params['name']},
    },
  );

  final server = serve(
    hostname: '0.0.0.0',
    port: 3000,
    reusePort: true,
    fetch: (request, _) => app.fetch(request),
  );
  await server.ready();
}

Future<void> main() async {
  // Run main server.
  await runServer();

  // Run cluster servers.
  for (int i = Platform.numberOfProcessors - 1; i > 0; i--) {
    await Isolate.spawn(runServer, null);
  }
}
