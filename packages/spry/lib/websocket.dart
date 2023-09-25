library spry.websocket;

import 'dart:io';

import 'spry.dart';

class WebSocketHandler {
  Future<void> call(Context context) async {
    final HttpRequest request = context[HttpRequest];

    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      throw Exception('Not a WebSocket upgrade request');
    }

    final websocket = await WebSocketTransformer.upgrade(request);
    websocket.listen((event) {
      print(event);
    });

    await websocket.done;
  }
}

final handler = WebSocketHandler();
final spry = Spry();

void main() async {
  await spry.listen(handler, port: 3030);
}
