import 'package:spry/spry.dart';

final app = Application.late();

void main(List<String> args) async {
  app.get('hello', (request) => 'Hello, Spry!');

  await app.run(port: 3000);

  print('Listening on http://localhost:3000');
}
