import 'package:spry/server.dart';

Future<void> main() async {
  final server = serve(
    hostname: 'localhost',
    port: 3000,
    fetch: (request, _) {
      return Response.fromString("Hey, I'm Cross Server!");
    },
  );
  await server.ready();
  print('🎉 Corss server listen on http://localhost:3000');
}
