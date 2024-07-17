import 'types.dart';

extension SpryUse on Spry {
  void use<T>(Handler<T> handler) {
    stack.add(handler);
  }
}
