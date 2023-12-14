import 'dart:io';

void main(List<String> args) {
  final server = HttpServer.bind('localhost', 3000);

  server.then((server) {
    server.listen((request) {
      request.response.write('Hello, world!');
      request.response.close();
    });
  });
}
