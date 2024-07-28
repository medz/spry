import 'package:spry/bun.dart';

import 'app.dart';

void main() async {
  final serve = toBunServe(app)..port = 3000;
  Bun.serve(serve);

  print('🎉 Server listen on http://127.0.0.1:3000');
}
