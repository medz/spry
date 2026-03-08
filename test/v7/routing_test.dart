import 'package:spry/app.dart';
import 'package:test/test.dart';

void main() {
  group('v7 handler matcher', () {
    test('matches exact method and exposes params', () {
      Object? getHandler(Event event) => null;
      final router = createHandlerRouter({
        '/users/:id': {HttpMethod.get: getHandler},
      });

      final matched = matchHandlerRoute(
        router,
        method: HttpMethod.get,
        path: '/users/42',
      );

      expect(matched, isNotNull);
      expect(matched!.path, '/users/:id');
      expect(matched.method, HttpMethod.get);
      expect(matched.handler, same(getHandler));
      expect(matched.params, {'id': '42'});
    });

    test('prefers HEAD over GET over any', () {
      Object? anyHandler(Event event) => null;
      Object? getHandler(Event event) => null;
      Object? headHandler(Event event) => null;
      final router = createHandlerRouter({
        '/health': {
          HttpMethod.any: anyHandler,
          HttpMethod.get: getHandler,
          HttpMethod.head: headHandler,
        },
      });

      final matched = matchHandlerRoute(
        router,
        method: HttpMethod.head,
        path: '/health',
      );

      expect(matched, isNotNull);
      expect(matched!.method, HttpMethod.head);
      expect(matched.handler, same(headHandler));
    });

    test('falls back from HEAD to GET before any', () {
      Object? anyHandler(Event event) => null;
      Object? getHandler(Event event) => null;
      final router = createHandlerRouter({
        '/health': {HttpMethod.any: anyHandler, HttpMethod.get: getHandler},
      });

      final matched = matchHandlerRoute(
        router,
        method: HttpMethod.head,
        path: '/health',
      );

      expect(matched, isNotNull);
      expect(matched!.method, HttpMethod.get);
      expect(matched.handler, same(getHandler));
    });

    test('falls back to any for other methods', () {
      Object? anyHandler(Event event) => null;
      final router = createHandlerRouter({
        '/health': {HttpMethod.any: anyHandler},
      });

      final matched = matchHandlerRoute(
        router,
        method: HttpMethod.post,
        path: '/health',
      );

      expect(matched, isNotNull);
      expect(matched!.method, HttpMethod.any);
      expect(matched.handler, same(anyHandler));
    });
  });

  group('v7 middleware collector', () {
    test('collects any and exact method matches in outer-to-inner order', () {
      Never rootAny(Event event, Next next) => throw UnimplementedError();
      Never rootGet(Event event, Next next) => throw UnimplementedError();
      Never apiAny(Event event, Next next) => throw UnimplementedError();
      Never apiGet(Event event, Next next) => throw UnimplementedError();

      final router = createMiddlewareRouter([
        MiddlewareRoute(path: '/*', handler: rootAny),
        MiddlewareRoute(path: '/*', method: HttpMethod.get, handler: rootGet),
        MiddlewareRoute(path: '/api/*', handler: apiAny),
        MiddlewareRoute(
          path: '/api/*',
          method: HttpMethod.get,
          handler: apiGet,
        ),
      ]);

      final matches = collectMiddlewareRoutes(
        router,
        method: HttpMethod.get,
        path: '/api/demo',
      );

      expect(matches, hasLength(4));
      expect(matches.map((match) => match.route.handler), [
        same(rootAny),
        same(rootGet),
        same(apiAny),
        same(apiGet),
      ]);
      expect(matches.first.params, {'wildcard': 'api/demo'});
      expect(matches[2].params, {'wildcard': 'demo'});
    });

    test('prefers broader scope before param route', () {
      Never apiWildcard(Event event, Next next) => throw UnimplementedError();
      Never apiDetail(Event event, Next next) => throw UnimplementedError();

      final router = createMiddlewareRouter([
        MiddlewareRoute(
          path: '/api/:id',
          method: HttpMethod.get,
          handler: apiDetail,
        ),
        MiddlewareRoute(
          path: '/api/*',
          method: HttpMethod.get,
          handler: apiWildcard,
        ),
      ]);

      final matches = collectMiddlewareRoutes(
        router,
        method: HttpMethod.get,
        path: '/api/demo',
      );

      expect(matches, hasLength(2));
      expect(matches.map((match) => match.route.handler), [
        same(apiWildcard),
        same(apiDetail),
      ]);
      expect(matches[1].params, {'id': 'demo'});
    });
  });

  group('v7 error collector', () {
    test('collects error handlers from inner scope to outer scope', () {
      Object? rootError(Object error, StackTrace stack, Event event) => null;
      Object? apiError(Object error, StackTrace stack, Event event) => null;

      final router = createErrorRouter([
        ErrorRoute(path: '/*', handler: rootError),
        ErrorRoute(path: '/api/*', handler: apiError),
      ]);

      final matches = collectErrorRoutes(
        router,
        method: HttpMethod.get,
        path: '/api/demo',
      );

      expect(matches, hasLength(2));
      expect(matches.map((match) => match.route.handler), [
        same(apiError),
        same(rootError),
      ]);
      expect(matches.first.params, {'wildcard': 'demo'});
      expect(matches[1].params, {'wildcard': 'api/demo'});
    });

    test('prefers exact method over any on the same scope', () {
      Object? apiAny(Object error, StackTrace stack, Event event) => null;
      Object? apiGet(Object error, StackTrace stack, Event event) => null;

      final router = createErrorRouter([
        ErrorRoute(path: '/api/*', handler: apiAny),
        ErrorRoute(path: '/api/*', method: HttpMethod.get, handler: apiGet),
      ]);

      final matches = collectErrorRoutes(
        router,
        method: HttpMethod.get,
        path: '/api/demo',
      );

      expect(matches, hasLength(2));
      expect(matches.map((match) => match.route.handler), [
        same(apiGet),
        same(apiAny),
      ]);
    });

    test('prefers more specific scope before broader scope', () {
      Object? wildcardError(Object error, StackTrace stack, Event event) =>
          null;
      Object? detailError(Object error, StackTrace stack, Event event) => null;

      final router = createErrorRouter([
        ErrorRoute(
          path: '/api/*',
          method: HttpMethod.get,
          handler: wildcardError,
        ),
        ErrorRoute(
          path: '/api/:id',
          method: HttpMethod.get,
          handler: detailError,
        ),
      ]);

      final matches = collectErrorRoutes(
        router,
        method: HttpMethod.get,
        path: '/api/demo',
      );

      expect(matches, hasLength(2));
      expect(matches.map((match) => match.route.handler), [
        same(detailError),
        same(wildcardError),
      ]);
      expect(matches.first.params, {'id': 'demo'});
    });
  });
}
