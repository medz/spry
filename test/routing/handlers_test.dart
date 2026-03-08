import 'package:spry/src/event.dart';
import 'package:spry/src/handler.dart';
import 'package:spry/src/routing/handlers.dart';
import 'package:test/test.dart';

void main() {
  group('createHandlerRouter', () {
    test('registers any-method handlers into the any bucket', () {
      final anyHandler = _handler('any');
      final router = createHandlerRouter({
        '/about': {null: anyHandler},
      });

      final match = router.match('/about', method: 'GET');

      expect(match, isNotNull);
      expect(identical(match!.data, anyHandler), isTrue);
    });

    test('registers method-specific handlers into method buckets', () {
      final getHandler = _handler('get');
      final postHandler = _handler('post');
      final router = createHandlerRouter({
        '/about': {'GET': getHandler, 'POST': postHandler},
      });

      final getMatch = router.match('/about', method: 'GET');
      final postMatch = router.match('/about', method: 'POST');

      expect(identical(getMatch!.data, getHandler), isTrue);
      expect(identical(postMatch!.data, postHandler), isTrue);
    });

    test('keeps any and method-specific handlers at the same path', () {
      final anyHandler = _handler('any');
      final getHandler = _handler('get');
      final router = createHandlerRouter({
        '/about': {null: anyHandler, 'GET': getHandler},
      });

      final getMatch = router.match('/about', method: 'GET');
      final postMatch = router.match('/about', method: 'POST');

      expect(identical(getMatch!.data, getHandler), isTrue);
      expect(identical(postMatch!.data, anyHandler), isTrue);
    });
  });
}

Handler _handler(String value) =>
    (Event event) => value;
