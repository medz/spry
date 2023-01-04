import 'package:spry/spry.dart';
import 'package:spry_static/spry_static.dart';

void main() async {
  final Spry spry = Spry();
  final Static static = Static.directory(
    directory: 'static',
    defaultFiles: ['index.html'],
  );

  await spry.listen(static, port: 3000);
  print('Listening on port http://localhost:3000');
}
