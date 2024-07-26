import 'package:spry/spry.dart';
import 'package:spry/bun.dart';
import 'package:spry/ws.dart';

void main() async {
  final app = createSpry();

  app.all('/**', (event) => 'Hello Spry!');
  app.ws('/ws', defineHooks(message: (peer, message) {
    peer.send(message);
  }));

  final serve = toBunServe(app)..port = 3000;
  Bun.serve(serve);
}
