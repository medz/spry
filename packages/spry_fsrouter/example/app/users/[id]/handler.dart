import 'package:spry/spry.dart';
import 'package:spry_router/spry_router.dart';

handler(Context context) {
  final String id = context.request.param('id') as String;

  context.response.send('Hello, $id!');
}
