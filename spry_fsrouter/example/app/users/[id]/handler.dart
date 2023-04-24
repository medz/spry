import 'package:spry/router.dart';
import 'package:spry/spry.dart';

handler(Context context) {
  final int id = context.request.param('id') as int;

  context.response.text('Hello, $id!');
}
