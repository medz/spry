import 'package:spry/spry.dart';
import 'package:spry_websocket/spry_websocket.dart';

void onConnection(Context context, WebSocketChannel channel) {
  channel.stream.listen((event) {
    channel.sink.add('Server received: $event');
  });
}

final spry = Spry();
final websocket = SpryWebSocket(onConnection);

void main() async {
  await spry.listen(websocket, port: 3030);

  print('🎉 Server is running at ws://localhost:3030');
}
