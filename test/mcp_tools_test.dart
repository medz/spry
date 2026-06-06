import 'package:ht/ht.dart' show HttpMethod;
import 'package:spry/src/builder/config.dart';
import 'package:spry/src/builder/scan_entry.dart';
import 'package:spry/src/mcp/mcp_tools.dart';
import 'package:test/test.dart';

void main() {
  late BuildConfig config;

  setUp(() {
    config = BuildConfig(rootDir: '/fake/project');
  });

  ProjectState newState(List<ScanEntry> entries) {
    return ProjectState(config: config, entries: entries);
  }

  // ------ Path matching ------

  group('pathMatches', () {
    test('exact match', () {
      expect(pathMatches('/users', '/users'), isTrue);
      expect(pathMatches('/users', '/posts'), isFalse);
    });

    test('match with named param', () {
      expect(pathMatches('/users/[id]', '/users/123'), isTrue);
      expect(pathMatches('/users/[id]', '/users'), isFalse);
      expect(pathMatches('/users/[id]', '/users/123/extra'), isFalse);
    });

    test('match with multiple params', () {
      expect(
        pathMatches('/users/[id]/posts/[pid]', '/users/1/posts/2'),
        isTrue,
      );
      expect(
        pathMatches('/users/[id]/posts/[pid]', '/users/1/comments/2'),
        isFalse,
      );
    });

    test('wildcard matches remaining segments including zero', () {
      expect(pathMatches('/[...slug]', '/a/b/c'), isTrue);
      expect(pathMatches('/[...slug]', '/'), isTrue);
      expect(pathMatches('/api/[...rest]', '/api/users/123'), isTrue);
    });

    test('regex param treated as any single segment', () {
      expect(pathMatches(r'/users/[id=\d+]', '/users/abc'), isTrue);
    });

    test('root path', () {
      expect(pathMatches('/', '/'), isTrue);
      expect(pathMatches('/', '/other'), isFalse);
    });
  });

  group('pathIsPrefix', () {
    test('exact prefix', () {
      expect(pathIsPrefix('/admin', '/admin/users'), isTrue);
      expect(pathIsPrefix('/admin', '/other'), isFalse);
    });

    test('prefix must match on path boundaries', () {
      expect(pathIsPrefix('/admin', '/admins'), isFalse);
      expect(pathIsPrefix('/api', '/api-v2'), isFalse);
    });

    test('glob patterns match everything', () {
      expect(pathIsPrefix('/**', '/anything'), isTrue);
      expect(pathIsPrefix('/*', '/anything'), isTrue);
    });

    test('exact match is a prefix', () {
      expect(pathIsPrefix('/admin', '/admin'), isTrue);
    });
  });

  group('extractParams', () {
    test('extracts named params', () {
      final params = extractParams('/users/[id]', '/users/42');
      expect(params, {'id': '42'});
    });

    test('extracts multiple params', () {
      final params = extractParams(
        '/users/[uid]/posts/[pid]',
        '/users/1/posts/99',
      );
      expect(params, {'uid': '1', 'pid': '99'});
    });

    test('extracts wildcard param', () {
      final params = extractParams('/[...slug]', '/a/b/c');
      expect(params, {'slug': 'a/b/c'});
    });

    test('extracts named param with regex', () {
      final params = extractParams(r'/users/[id=\d+]', '/users/42');
      expect(params, {'id': '42'});
    });

    test('no params for literal match', () {
      final params = extractParams('/about', '/about');
      expect(params, isEmpty);
    });
  });

  // ------ Tool dispatch ------

  group('handleToolCall', () {
    test('dispatches to get_project_info', () {
      final result = handleToolCall(
        'spry.get_project_info',
        null,
        newState([]),
      );

      expect(result, isA<Map<String, dynamic>>());
      final info = result as Map<String, dynamic>;
      expect(info['target'], 'vm');
      expect(info['route_count'], 0);
      expect(info['middleware_count'], 0);
    });

    test('throws on unknown tool', () {
      expect(
        () => handleToolCall('unknown', null, newState([])),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('get_config returns all config fields', () {
      final result = handleToolCall('spry.get_config', null, newState([]));

      final cfg = result as Map<String, dynamic>;
      expect(cfg['host'], '0.0.0.0');
      expect(cfg['port'], 3000);
      expect(cfg['target'], 'vm');
      expect(cfg['routes_dir'], 'routes');
      expect(cfg['case_sensitive'], isTrue);
    });

    test('list_routes returns route entries', () {
      final ps = newState([
        ScanEntry.route(
          RouteEntry(
            filePath: '/fake/routes/index.dart',
            path: '/',
            method: null,
          ),
        ),
        ScanEntry.route(
          RouteEntry(
            filePath: '/fake/routes/users.get.dart',
            path: '/users',
            method: HttpMethod.get,
          ),
        ),
      ]);

      final result = handleToolCall('spry.list_routes', null, ps);
      final routes = result as List<dynamic>;

      expect(routes.length, 2);
      expect(routes[0]['path'], '/');
      expect(routes[1]['method'], 'GET');
    });

    test('list_middleware separates global and scoped', () {
      final ps = newState([
        ScanEntry.globalMiddleware(
          MiddlewareEntry(
            filePath: '/fake/middleware/logger.dart',
            path: '/**',
          ),
        ),
        ScanEntry.scopedMiddleware(
          MiddlewareEntry(
            filePath: '/fake/routes/admin/_middleware.dart',
            path: '/admin',
          ),
        ),
      ]);

      final result = handleToolCall('spry.list_middleware', null, ps);
      final mw = result as List<dynamic>;

      expect(mw.length, 2);
      expect(mw[0]['type'], 'global');
      expect(mw[1]['type'], 'scoped');
      expect(mw[1]['path'], '/admin');
    });

    test('list_error_handlers returns error entries', () {
      final ps = newState([
        ScanEntry.scopedError(
          ErrorEntry(filePath: '/fake/routes/_error.dart', path: '/'),
        ),
      ]);

      final result = handleToolCall('spry.list_error_handlers', null, ps);
      final errors = result as List<dynamic>;

      expect(errors.length, 1);
      expect(errors[0]['path'], '/');
    });

    test('explain_route matches route and collects middleware', () {
      final ps = newState([
        ScanEntry.route(
          RouteEntry(
            filePath: '/fake/routes/users/[id].dart',
            path: '/users/[id]',
            method: HttpMethod.get,
          ),
        ),
        ScanEntry.globalMiddleware(
          MiddlewareEntry(
            filePath: '/fake/middleware/logger.dart',
            path: '/**',
          ),
        ),
        ScanEntry.scopedError(
          ErrorEntry(filePath: '/fake/routes/_error.dart', path: '/'),
        ),
      ]);

      final result = handleToolCall('spry.explain_route', {
        'method': 'GET',
        'path': '/users/42',
      }, ps);

      final explanation = result as Map<String, dynamic>;
      expect(explanation['method'], 'GET');
      expect(explanation['path'], '/users/42');

      final routes = explanation['matched_routes'] as List<dynamic>;
      expect(routes.length, 1);
      expect(routes[0]['params'], {'id': '42'});

      final middleware = explanation['middleware_chain'] as List<dynamic>;
      expect(middleware.length, 1);
      expect(middleware[0]['type'], 'global');

      final errors = explanation['error_handlers'] as List<dynamic>;
      expect(errors.length, 1);
    });

    test('get_openapi_status when disabled', () {
      final result = handleToolCall(
        'spry.get_openapi_status',
        null,
        newState([]),
      );

      final status = result as Map<String, dynamic>;
      expect(status['enabled'], isFalse);
    });

    test('get_client_status when disabled', () {
      final result = handleToolCall(
        'spry.get_client_status',
        null,
        newState([]),
      );

      final status = result as Map<String, dynamic>;
      expect(status['enabled'], isFalse);
    });
  });

  group('get_project_info', () {
    test('counts routes, middleware, and errors', () {
      final ps = newState([
        ScanEntry.route(
          RouteEntry(filePath: '/routes/a.dart', path: '/a', method: null),
        ),
        ScanEntry.route(
          RouteEntry(filePath: '/routes/b.dart', path: '/b', method: null),
        ),
        ScanEntry.globalMiddleware(
          MiddlewareEntry(filePath: '/middleware/log.dart', path: '/**'),
        ),
        ScanEntry.scopedError(
          ErrorEntry(filePath: '/routes/_error.dart', path: '/'),
        ),
      ]);

      final result = handleToolCall('spry.get_project_info', null, ps);

      final info = result as Map<String, dynamic>;
      expect(info['route_count'], 2);
      expect(info['middleware_count'], 1);
      expect(info['error_handler_count'], 1);
      expect(info['target'], 'vm');
    });
  });
}
