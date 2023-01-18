import 'package:http/http.dart' as http;
import 'package:spry/spry.dart';

// Benchmark, time from starting an http server to successful access.

void main() async {
  final Uri uri = Uri.parse('http://localhost:3000');

  // Spry
  final Spry spry = Spry();

  spry.use((Context context, Next next) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    await next();

    stopwatch.stop();
    print('Spry: ${stopwatch.elapsedMicroseconds}µs');
    print('Spry: ${stopwatch.elapsedMilliseconds}ms');
  });

  spryHandler(Context context) {
    context.response
      ..status(200)
      ..text('Hello, world!');
  }

  final spryServer =
      await spry.listen(spryHandler, port: 3000, address: 'localhost');
  final http.Response spryResponse = await http.get(uri);

  await spryServer.close();

  if (spryResponse.statusCode != 200) {
    throw Exception('Spry failed to respond with 200 OK.');
  }
}
