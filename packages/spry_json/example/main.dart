import 'package:spry/spry.dart';
import 'package:spry_json/spry_json.dart';

void main() {
  final Spry spry = Spry();

  handler(Context context) async {
    final json = await context.request.json;

    context.response.json(json);
  }

  spry.listen(handler, port: 3000);

  print('Listening on http://localhost:3000');
}
