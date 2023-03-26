import 'package:spry/spry.dart';
import 'package:spry_router/spry_router.dart';

Future<void> middleware(Context context, Object? value, ParamNext next) async {
  final int id = int.parse(value.toString());

  await next(id);
}
