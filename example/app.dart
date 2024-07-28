import 'package:spry/spry.dart';
import 'package:spry/ws.dart';

final app = createSpry()
  ..get('/', (event) => 'Hello Spry!')
  ..ws('/ws', defineHooks(message: (peer, message) {
    final text = message.text();
    print('[WS] message: $text');
    if (text.toLowerCase().contains('ping')) {
      peer.send(Message.text('pong'));
    }
  }))
  ..all('/**', (event) => 'Fallback');
