import 'package:spry/spry.dart';
import 'package:spry_json/spry_json.dart';

void main() {
  final Spry spry = Spry();

  handler(Context context) {
    context.response.json({'foo': 'bar'});
  }

  spry.listen(handler, port: 3000);

  print('Listening on http://localhost:3000');
}
