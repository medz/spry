import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

// Benchmark, time from starting an http server to successful access.

void main() async {
  final Uri uri = Uri.parse('http://localhost:3000');

  // Shelf
  final Handler shelfHandler = Pipeline().addMiddleware(((innerHandler) {
    final Stopwatch stopwatch = Stopwatch()..start();

    return (Request request) async {
      final Response response = await innerHandler(request);

      stopwatch.stop();
      print('Shelf: ${stopwatch.elapsedMicroseconds}µs');
      print('Shelf: ${stopwatch.elapsedMilliseconds}ms');

      return response;
    };
  })).addHandler((Request request) {
    return Response.ok('Hello, world!');
  });

  final shelfServer = await shelf_io.serve(shelfHandler, 'localhost', 3000);
  final http.Response shelfResponse = await http.get(uri);

  await shelfServer.close();

  if (shelfResponse.statusCode != 200) {
    throw Exception('Shelf failed to respond with 200 OK.');
  }
}
