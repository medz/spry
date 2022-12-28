import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

// Benchmark, time from starting an http server to successful access.

void main() async {
  final Uri uri = Uri.parse('http://localhost:3000');

  // Shelf
  final shelf.Handler shelfHandler =
      shelf.Pipeline().addMiddleware(((innerHandler) {
    final Stopwatch stopwatch = Stopwatch()..start();

    return (shelf.Request request) async {
      final shelf.Response response = await innerHandler(request);

      stopwatch.stop();
      print('Shelf: ${stopwatch.elapsedMicroseconds}µs');
      print('Shelf: ${stopwatch.elapsedMilliseconds}ms');

      return response;
    };
  })).addHandler((shelf.Request request) {
    return shelf.Response.ok('Hello, world!');
  });

  final shelfServer = await shelf_io.serve(shelfHandler, 'localhost', 3000);
  final http.Response shelfResponse = await http.get(uri);

  await shelfServer.close();

  if (shelfResponse.statusCode != 200) {
    throw Exception('Shelf failed to respond with 200 OK.');
  }
}
