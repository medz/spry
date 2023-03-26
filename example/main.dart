import 'dart:io';

import 'package:spry/spry.dart';

void main() async {
  final Spry spry = Spry();

  // logger
  spry.use((Context context, Next next) async {
    await next();

    final Response response = context.response;
    final String? rt = response.headers.value('x-response-time');

    print('${context.request.method} ${context.request.uri} - $rt');
  });

  // x-response-time
  spry.use((Context context, Next next) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    await next();

    stopwatch.stop();
    context.response.headers
        .set('x-response-time', '${stopwatch.elapsedMilliseconds}ms');
  });

  // Create handler
  handler(Context context) {
    context.response.statusCode = HttpStatus.ok;
    context.response.text('Hello World!');
  }

  // Listen
  final server = await spry.listen(handler, port: 3000);

  print('Server running at http://localhost:${server.port}/');
}
