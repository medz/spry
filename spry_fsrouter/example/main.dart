import 'package:spry/spry.dart';

import 'app/app.dart';

void main() async {
  final Spry spry = Spry();

  await spry.listen(app, port: 8080);
  print('Listening on http://localhost:8080');
}
