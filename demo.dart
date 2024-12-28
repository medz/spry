import 'src/http/response.dart';
import 'src/server/serve.dart';

Future<void> main() async {
  final server = serve(
    hostname: 'localhost',
    port: 3000,
    fetch: (request, server) {
      return Response.fromJson(
        body: {'query': request.url.query, 'test': 1},
      );
    },
  );

  await server.ready();
  print('🎉 Server listen on http://localhost:3000');
}
