import 'package:spry/spry.dart';
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
        '/about': {HttpMethod.get: getHandler, HttpMethod.post: postHandler},
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
        '/about': {null: anyHandler, HttpMethod.get: getHandler},
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
        '/about': {null: anyHandler, HttpMethod.get: getHandler},
      });

      final match = matchHandler(router, '/about', 'GET');

      expect(match, isNotNull);
      expect(identical(match!.data, getHandler), isTrue);
    });

    test('falls back from HEAD to GET', () {
      final getHandler = _handler('get');
      final router = createHandlerRouter({
        '/about': {HttpMethod.get: getHandler},
      });

      final match = matchHandler(router, '/about', 'HEAD');

      expect(match, isNotNull);
      expect(identical(match!.data, getHandler), isTrue);
    });

    test('prefers HEAD over GET for HEAD requests', () {
      final headHandler = _handler('head');
      final getHandler = _handler('get');
      final router = createHandlerRouter({
        '/about': {HttpMethod.head: headHandler, HttpMethod.get: getHandler},
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
        '/about': {HttpMethod.get: _handler('get')},
      });

      final match = matchHandler(router, '/missing', 'GET');

      expect(match, isNull);
    });
  });

  group('createMiddlewareRouter', () {
    test('matchAll returns outer-to-inner scopes', () {
      final global = _middleware('global');
      final api = _middleware('api');
      final users = _middleware('users');
      final router = createMiddlewareRouter([
        MiddlewareRoute(path: '/**', handler: global),
        MiddlewareRoute(path: '/api/**', handler: api),
        MiddlewareRoute(path: '/api/users/**', handler: users),
      ]);

      final matches = router.matchAll('/api/users/1', method: 'GET');

      expect(matches.map((match) => match.data), [
        same(global),
        same(api),
        same(users),
      ]);
    });

    test('matchAll keeps any-method before method-specific at same scope', () {
      final anyRoute = MiddlewareRoute(
        path: '/api/**',
        handler: _middleware('any'),
      );
      final getRoute = MiddlewareRoute(
        path: '/api/**',
        method: HttpMethod.get,
        handler: _middleware('get'),
      );
      final router = createMiddlewareRouter([anyRoute, getRoute]);

      final matches = router.matchAll('/api/demo', method: 'GET');

      expect(matches, hasLength(2));
      expect(matches[0].data, same(anyRoute.handler));
      expect(matches[1].data, same(getRoute.handler));
    });

    test('keeps multiple handlers at the same scope and method', () {
      final first = MiddlewareRoute(path: '/**', handler: _middleware('first'));
      final second = MiddlewareRoute(
        path: '/**',
        handler: _middleware('second'),
      );
      final router = createMiddlewareRouter([first, second]);

      final matches = router.matchAll('/demo', method: 'GET');

      expect(matches, hasLength(2));
      expect(matches[0].data, same(first.handler));
      expect(matches[1].data, same(second.handler));
    });
  });

  group('createErrorRouter', () {
    test('matchAll returns candidates from outer-to-inner specificity', () {
      final global = _errorHandler('global');
      final api = _errorHandler('api');
      final user = _errorHandler('user');
      final router = createErrorRouter([
        ErrorRoute(path: '/**', handler: global),
        ErrorRoute(path: '/api/**', handler: api),
        ErrorRoute(path: '/api/users/:id', handler: user),
      ]);

      final matches = router.matchAll('/api/users/1', method: 'GET');

      expect(matches.map((match) => match.data), [
        same(global),
        same(api),
        same(user),
      ]);
    });

    test('matchAll includes any-method and exact-method candidates', () {
      final anyRoute = ErrorRoute(
        path: '/api/**',
        handler: _errorHandler('any'),
      );
      final getRoute = ErrorRoute(
        path: '/api/**',
        method: HttpMethod.get,
        handler: _errorHandler('get'),
      );
      final router = createErrorRouter([anyRoute, getRoute]);

      final matches = router.matchAll('/api/demo', method: 'GET');

      expect(matches, hasLength(2));
      expect(matches[0].data, same(anyRoute.handler));
      expect(matches[1].data, same(getRoute.handler));
    });
  });

  group('error ordering', () {
    test('returns candidates from inner to outer', () {
      final global = _errorHandler('global');
      final api = _errorHandler('api');
      final user = _errorHandler('user');
      final router = createErrorRouter([
        ErrorRoute(path: '/**', handler: global),
        ErrorRoute(path: '/api/**', handler: api),
        ErrorRoute(path: '/api/users/:id', handler: user),
      ]);

      final matches = router.matchAll('/api/users/1', method: 'GET').reversed;

      expect(matches.map((match) => match.data), [
        same(user),
        same(api),
        same(global),
      ]);
    });

    test('prefers exact method before any-method at the same scope', () {
      final anyRoute = ErrorRoute(
        path: '/api/**',
        handler: _errorHandler('any'),
      );
      final getRoute = ErrorRoute(
        path: '/api/**',
        method: HttpMethod.get,
        handler: _errorHandler('get'),
      );
      final router = createErrorRouter([anyRoute, getRoute]);

      final matches = router
          .matchAll('/api/demo', method: 'GET')
          .reversed
          .toList();

      expect(matches, hasLength(2));
      expect(matches[0].data, same(getRoute.handler));
      expect(matches[1].data, same(anyRoute.handler));
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
