import 'package:spry/plain.dart';
import 'package:spry/spry.dart';

void main() async {
  // Creates a Spry application.
  final app = Spry();

  // Adds a `GET /hello` route, Response body with 'Hello Spry!'
  app.get('hello', (event) => 'Hello Spry!');

  // Creates a plain platfrom.
  const plain = PlainPlatform();

  // Creates a plain platfrom handler.
  final handler = plain.createHandler(app);

  final request = PlainRequest(method: 'get', uri: Uri(path: 'hello'));
  final response = await handler(request);

  print(await response.text()); // Hello Spry!
}
