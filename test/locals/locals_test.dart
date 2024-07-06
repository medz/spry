import 'package:spry/spry.dart';
import 'package:spry/src/locals/locals.dart';
import 'package:test/test.dart';

void main() {
  test('.set', () {
    final locals = LocalsImpl();

    locals.set('a', 1);
    locals.set(#app, 2);

    expect(locals.locals['a'], equals(1));
    expect(locals.locals[#app], equals(2));
    expect(locals.locals[1], isNull);
  });

  test('.get', () {
    final locals = LocalsImpl();

    locals.set(#app, 1);

    expect(locals.get(#app), equals(1));
    expect(locals.get<int>(#app), equals(1));
    expectLater(() => locals.get<String>(#app), throwsA(isA<TypeError>()));
  });

  test('.getOrNull', () {
    final locals = LocalsImpl();

    locals.set(#app, 1);

    expect(locals.getOrNull(#app), equals(1));
    expect(locals.getOrNull<int>(#app), equals(1));
    expect(locals.getOrNull<String>(#app), isNull);
    expect(locals.getOrNull('demo'), isNull);
  });
}
