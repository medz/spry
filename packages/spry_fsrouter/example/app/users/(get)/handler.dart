import 'package:spry/spry.dart';

handler(Context context) {
  context.response.send('child(/users/(get))');
}
