import 'dart:io';

import 'package:spry/spry.dart';
import 'package:spry_session/spry_session.dart';

void main() async {
  final Spry spry = Spry();

  handler(Context context) {
    final HttpSession session = context.session;

    session['foo'] = 'bar';

    context.response.text('Stored foo in session, Session ID: ${session.id}');
  }

  await spry.listen(handler, port: 3000);

  print('Listening on port 3000');
}
