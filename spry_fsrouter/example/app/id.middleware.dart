import 'package:spry/router.dart';
import 'package:spry/spry.dart';

Future<void> middleware(Context context, Object? value, ParamNext next) async {
  final int id = int.parse(value.toString());

  await next(id);
}
