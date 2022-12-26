import 'dart:io';

import 'package:spry/spry.dart';

void main() async {
  final Spry spry = Spry();

  // logger
  spry.use((Context context, MiddlewareNext next) async {
    await next();

    final Response response = context.response;
    final String? rt = response.headers.value('x-response-time');

    print('${context.request.method} ${context.request.uri} - $rt');
  });

  // x-response-time
  spry.use((Context context, MiddlewareNext next) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    await next();

    stopwatch.stop();
    context.response.headers
        .set('x-response-time', '${stopwatch.elapsedMilliseconds}ms');
  });

  // Create handler
  final handler = spry((Context context) {
    context.response.statusCode = HttpStatus.ok;
    context.response.send('Hello World!');
  });

  // Create server
  final server = await HttpServer.bind('localhost', 3000);

  // Listen for requests
  server.listen(handler);

  print('Server running at http://localhost:3000/');
}
