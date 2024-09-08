import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spry/io.dart';
import 'package:spry/spry.dart';

void main() async {
  final app = createSpry();

  app.get('/', (event) async {
    event.set(#spry.io.websocket.uograded, true);

    final request = useRequest(event).body as HttpRequest;
    final response = request.response;

    response.headers.contentType = ContentType.parse('text/event-stream');
    response.statusCode = 200;
    response.headers.set('Cache-Control', 'no-cache');
    response.headers.set('Connection', 'keep-alive');
    response.headers.chunkedTransferEncoding = false;

    final socket = await request.response.detachSocket(writeHeaders: true);
    final controller = StreamController<String>();

    controller.stream.listen((bytes) {
      socket.write('data: ');
      socket.write(bytes);
      socket.write('\n\n');
    });

    Timer.periodic(Duration(seconds: 3), (timer) {
      if (controller.isClosed) {
        return timer.cancel();
      }

      controller
          .add(json.encode({"id": "xxx", "message": "count: ${timer.tick}"}));
    });

    socket.listen((_) {}, onDone: () {
      print(11111);
      unawaited(controller.close());
    });
  });

  final handler = toIOHandler(app);
  final server = await HttpServer.bind('127.0.0.1', 3000);

  server.listen(handler);

  print('🎉 Server listen on http://127.0.0.1:3000');
}
