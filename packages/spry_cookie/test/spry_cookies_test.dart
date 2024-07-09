import 'package:spry/spry.dart';
import 'package:spry/plain.dart';
import 'package:spry_cookie/spry_cookie.dart';

void main() async {
  final app = Spry();

  app.use(cookie(
    domain: 'spry.fun',
    secret: "",
  ));

  app.all('/', (event) {
    event.cookies
        .set('a', '你好', httpOnly: false, expires: DateTime.now(), maxAge: 12);

    print(event.cookies.get('a'));
  });

  final handler = app.toPlainHandler();
  final request = PlainRequest(method: 'get', uri: Uri(scheme: 'https'));
  final response = await handler(request);

  for (final header in response.headers) {
    print(header);
  }
}
