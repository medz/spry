import 'package:spry/spry.dart';
import 'package:spry_urlencoded/spry_urlencoded.dart';

final spry = Spry();
final urlencoded = Urlencoded();

void handler(Context context) async {
  final urlencoded = await context.request.urlencoded();

  print(urlencoded);
}

void main() async {
  spry.use(urlencoded);
  await spry.listen(handler, port: 3000);

  print('Listening on http://localhost:3000');
}
