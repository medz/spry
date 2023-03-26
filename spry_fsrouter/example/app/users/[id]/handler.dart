import 'package:spry/spry.dart';
import 'package:spry_router/spry_router.dart';

handler(Context context) {
  final int id = context.request.param('id') as int;

  context.response.text('Hello, $id!');
}
