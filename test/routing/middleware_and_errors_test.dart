import 'package:ht/ht.dart';
import 'package:spry/src/error_route.dart';
import 'package:spry/src/event.dart';
import 'package:spry/src/handler.dart';
import 'package:spry/src/middleware.dart';
import 'package:spry/src/routing/errors.dart';
import 'package:spry/src/routing/middleware.dart';
import 'package:test/test.dart';

void main() {
  group('createMiddlewareRouter', () {
    test('matchAll returns outer-to-inner scopes', () {
      final router = createMiddlewareRouter([
        MiddlewareRoute(path: '/*', handler: _middleware('global')),
        MiddlewareRoute(path: '/api/*', handler: _middleware('api')),
        MiddlewareRoute(path: '/api/users/*', handler: _middleware('users')),
      ]);

      final matches = router.matchAll('/api/users/1', method: 'GET');

      expect(matches.map((match) => match.data.path), [
        '/*',
        '/api/*',
        '/api/users/*',
      ]);
    });

    test('matchAll keeps any-method before method-specific at same scope', () {
      final anyRoute = MiddlewareRoute(
        path: '/api/*',
        handler: _middleware('any'),
      );
      final getRoute = MiddlewareRoute(
        path: '/api/*',
        method: 'GET',
        handler: _middleware('get'),
      );
      final router = createMiddlewareRouter([anyRoute, getRoute]);

      final matches = router.matchAll('/api/demo', method: 'GET');

      expect(matches, hasLength(2));
      expect(identical(matches[0].data, anyRoute), isTrue);
      expect(identical(matches[1].data, getRoute), isTrue);
    });
  });

  group('createErrorRouter', () {
    test('matchAll returns candidates from outer-to-inner specificity', () {
      final router = createErrorRouter([
        ErrorRoute(path: '/*', handler: _errorHandler('global')),
        ErrorRoute(path: '/api/*', handler: _errorHandler('api')),
        ErrorRoute(path: '/api/users/:id', handler: _errorHandler('user')),
      ]);

      final matches = router.matchAll('/api/users/1', method: 'GET');

      expect(matches.map((match) => match.data.path), [
        '/*',
        '/api/*',
        '/api/users/:id',
      ]);
    });

    test('matchAll includes any-method and exact-method candidates', () {
      final anyRoute = ErrorRoute(
        path: '/api/*',
        handler: _errorHandler('any'),
      );
      final getRoute = ErrorRoute(
        path: '/api/*',
        method: 'GET',
        handler: _errorHandler('get'),
      );
      final router = createErrorRouter([anyRoute, getRoute]);

      final matches = router.matchAll('/api/demo', method: 'GET');

      expect(matches, hasLength(2));
      expect(identical(matches[0].data, anyRoute), isTrue);
      expect(identical(matches[1].data, getRoute), isTrue);
    });
  });

  group('collectErrors', () {
    test('returns candidates from inner to outer', () {
      final router = createErrorRouter([
        ErrorRoute(path: '/*', handler: _errorHandler('global')),
        ErrorRoute(path: '/api/*', handler: _errorHandler('api')),
        ErrorRoute(path: '/api/users/:id', handler: _errorHandler('user')),
      ]);

      final matches = collectErrors(router, '/api/users/1', 'GET');

      expect(matches.map((match) => match.data.path), [
        '/api/users/:id',
        '/api/*',
        '/*',
      ]);
    });

    test('prefers exact method before any-method at the same scope', () {
      final anyRoute = ErrorRoute(
        path: '/api/*',
        handler: _errorHandler('any'),
      );
      final getRoute = ErrorRoute(
        path: '/api/*',
        method: 'GET',
        handler: _errorHandler('get'),
      );
      final router = createErrorRouter([anyRoute, getRoute]);

      final matches = collectErrors(router, '/api/demo', 'GET').toList();

      expect(matches, hasLength(2));
      expect(identical(matches[0].data, getRoute), isTrue);
      expect(identical(matches[1].data, anyRoute), isTrue);
    });
  });
}

Middleware _middleware(String value) {
  return (Event event, Next next) async {
    return Response(body: value);
  };
}

ErrorHandler _errorHandler(String value) {
  return (Object error, StackTrace stackTrace, Event event) async {
    return Response.text(value);
  };
}
