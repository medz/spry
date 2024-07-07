import 'package:spry/plain.dart';
import 'package:spry/spry.dart';

const plain = PlainPlatform();

void main() async {
  final app = Spry();

  app.use((event) {
    print(1);
    event.cookies.set('a', '1');
  });

  app.use((event) {
    print(2);
    print(event.cookies.get('a'));
    event.cookies.delete('a');
  });

  app.use((event) {
    print(event.request.uri);
  });

  final handler = plain.createHandler(app);
  // OR
  // final handler = app.createPlatformHandler(plain);

  final request = PlainRequest(method: 'get', uri: Uri(path: '/haha'));
  final response = await handler(request);

  print(response.headers);
}
