import 'dart:io';

import 'package:http/http.dart';
import 'package:spry/spry.dart';
import 'package:test/test.dart';

import 'testkit.dart';

void main() {
  late HttpServer server;
  final spry = Spry();

  void handler(Context context) {
    context.response.statusCode = 200;
    context.response.stream(context.request.stream());
  }

  setUpAll(() async => server = await startServer(spry(handler)));
  tearDownAll(() async => server.close(force: true));

  test('GET /', () async {
    final endpoint = serverUri(server);
    final response = await get(endpoint);

    expect(response.statusCode, 200);
    // expect(response.body, 'Hello, world!');
  });
}
