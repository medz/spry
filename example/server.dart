import 'package:spry/server.dart';

Future<void> main() async {
  final server = serve(
    hostname: 'localhost',
    port: 3000,
    fetch: (request, _) {
      return Response.fromString("Hey, I'm Spry cross server!");
    },
  );
  await server.ready();
  print('🎉 Server listen on ${server.url}');
}
