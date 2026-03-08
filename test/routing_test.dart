import 'package:ht/ht.dart';
import 'package:spry/src/error_route.dart';
import 'package:spry/src/event.dart';
import 'package:spry/src/handler.dart';
import 'package:spry/src/middleware.dart';
import 'package:spry/src/routing.dart';
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

  group('matchHandler', () {
    test('prefers exact method matches', () {
      final anyHandler = _handler('any');
      final getHandler = _handler('get');
      final router = createHandlerRouter({
        '/about': {null: anyHandler, 'GET': getHandler},
      });

      final match = matchHandler(router, '/about', 'GET');

      expect(match, isNotNull);
      expect(identical(match!.data, getHandler), isTrue);
    });

    test('falls back from HEAD to GET', () {
      final getHandler = _handler('get');
      final router = createHandlerRouter({
        '/about': {'GET': getHandler},
      });

      final match = matchHandler(router, '/about', 'HEAD');

      expect(match, isNotNull);
      expect(identical(match!.data, getHandler), isTrue);
    });

    test('prefers HEAD over GET for HEAD requests', () {
      final headHandler = _handler('head');
      final getHandler = _handler('get');
      final router = createHandlerRouter({
        '/about': {'HEAD': headHandler, 'GET': getHandler},
      });

      final match = matchHandler(router, '/about', 'HEAD');

      expect(match, isNotNull);
      expect(identical(match!.data, headHandler), isTrue);
    });

    test('falls back to any-method handlers for non-HEAD requests', () {
      final anyHandler = _handler('any');
      final router = createHandlerRouter({
        '/about': {null: anyHandler},
      });

      final match = matchHandler(router, '/about', 'POST');

      expect(match, isNotNull);
      expect(identical(match!.data, anyHandler), isTrue);
    });

    test('returns null when no path matches', () {
      final router = createHandlerRouter({
        '/about': {'GET': _handler('get')},
      });

      final match = matchHandler(router, '/missing', 'GET');

      expect(match, isNull);
    });
  });

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

  group('error ordering', () {
    test('returns candidates from inner to outer', () {
      final router = createErrorRouter([
        ErrorRoute(path: '/*', handler: _errorHandler('global')),
        ErrorRoute(path: '/api/*', handler: _errorHandler('api')),
        ErrorRoute(path: '/api/users/:id', handler: _errorHandler('user')),
      ]);

      final matches = router.matchAll('/api/users/1', method: 'GET').reversed;

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

      final matches = router
          .matchAll('/api/demo', method: 'GET')
          .reversed
          .toList();

      expect(matches, hasLength(2));
      expect(identical(matches[0].data, getRoute), isTrue);
      expect(identical(matches[1].data, anyRoute), isTrue);
    });
  });
}

Handler _handler(String value) =>
    (Event event) => Response.text(value);

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
