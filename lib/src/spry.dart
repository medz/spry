import '_constant.dart';
import 'locals/locals.dart';

class Spry {
  Spry() {
    locals.set(kAppInstance, this);
  }

  final Locals locals = LocalsImpl();
}
