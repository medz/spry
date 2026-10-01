import 'dart:io';

import 'package:ht/ht.dart' show HttpMethod;
import 'package:spry/config.dart';
import 'package:spry/openapi.dart' show OpenAPIInfo;
import 'package:path/path.dart' as p;
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

  Map<String, dynamic> explain(
    List<ScanEntry> entries,
    String path, {
    String method = 'GET',
  }) =>
      handleToolCall('spry.explain_route', {
            'method': method,
            'path': path,
          }, newState(entries))
          as Map<String, dynamic>;

  ScanEntry route(String path, {HttpMethod? method = HttpMethod.get}) =>
      ScanEntry.route(
        RouteEntry(filePath: '/routes/$path.dart', path: path, method: method),
      );

  group('runtime route explanations', () {
    test(
      'public assets bypass routes and middleware for GET and HEAD',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'spry_public_inspection_',
        );
        addTearDown(() => root.delete(recursive: true));
        config = BuildConfig(rootDir: root.path);
        final public = Directory(p.join(root.path, 'public'));
        await public.create();
        await File(p.join(public.path, 'index.html')).writeAsString('root');
        await Directory(p.join(public.path, 'docs')).create();
        await File(
          p.join(public.path, 'docs', 'index.html'),
        ).writeAsString('docs');
        final entries = [
          route('/', method: null),
          ScanEntry.globalMiddleware(
            MiddlewareEntry(filePath: '/mw.dart', path: '/**'),
          ),
          ScanEntry.scopedError(
            ErrorEntry(filePath: '/error.dart', path: '/**'),
          ),
        ];
        for (final path in ['/', '/docs', '/docs/']) {
          for (final method in ['GET', 'HEAD']) {
            final result = explain(entries, path, method: method);
            expect(result['public_asset'], isNotNull);
            expect(result['matched_routes'], isEmpty);
            expect(result['middleware_chain'], isEmpty);
            expect(result['error_handlers'], isEmpty);
          }
        }
        expect(
          explain(entries, '/', method: 'POST')['matched_routes'],
          hasLength(1),
        );
        expect(explain(entries, '/missing')['public_asset'], isNull);
        expect(explain(entries, '/../index.html')['public_asset'], isNull);
        config = config.copyWith(publicDir: '');
        expect(explain(entries, '/')['matched_routes'], hasLength(1));
      },
    );
    test('generated Scalar route replaces filesystem handlers at its path', () {
      config = BuildConfig(
        rootDir: '/fake/project',
        openapi: OpenAPIConfig(
          document: OpenAPIDocumentConfig(
            info: OpenAPIInfo(title: 'Test API', version: '1'),
          ),
          output: OpenAPIOutput.route('openapi.json'),
          ui: Scalar(),
        ),
      );
      final entries = [route('/_docs', method: HttpMethod.post)];
      final match =
          (explain(entries, '/_docs', method: 'HEAD')['matched_routes'] as List)
              .single;
      expect(match['method'], 'GET');
      expect(
        match['file'],
        p.join(config.rootDir, config.outputDir, 'src/app.dart'),
      );
      expect(
        explain(entries, '/_docs', method: 'POST')['matched_routes'],
        isEmpty,
      );
      final state = newState(entries);
      expect(
        handleToolCall('spry.list_routes', null, state) as List,
        hasLength(1),
      );
      expect(
        (handleToolCall('spry.get_project_info', null, state)
            as Map)['route_count'],
        1,
      );
      config = config.copyWith(
        openapi: {
          'document': {
            'info': {'title': 'Test API', 'version': '1'},
          },
          'output': {'type': 'local', 'path': 'openapi.json'},
          'ui': {'route': '/_docs'},
        },
      );
      expect(explain([], '/_docs')['matched_routes'], isEmpty);
    });
    test('HEAD uses GET only when no HEAD or any-method handler matches', () {
      final get = route('/users');
      expect(
        (explain([get], '/users', method: 'HEAD')['matched_routes'] as List)
            .single['method'],
        'GET',
      );
      final head = route('/users', method: HttpMethod.head);
      expect(
        (explain([get, head], '/users', method: 'HEAD')['matched_routes']
                as List)
            .single['method'],
        'HEAD',
      );
      final any = route('/users', method: null);
      expect(
        (explain([get, any], '/users', method: 'HEAD')['matched_routes']
                as List)
            .single['method'],
        isNull,
      );
    });

    test('regex constraints and embedded parameters follow roux', () {
      final entries = [route(r'/users/:id(\d+)'), route('/files/:name.:ext')];
      expect(explain(entries, '/users/abc')['matched_routes'], isEmpty);
      expect(
        (explain(entries, '/users/42')['matched_routes'] as List)
            .single['params'],
        {'id': '42'},
      );
      expect(
        (explain(entries, '/files/report.pdf')['matched_routes'] as List)
            .single['params'],
        {'name': 'report', 'ext': 'pdf'},
      );
    });

    test('optional and repeated parameters retain runtime captures', () {
      expect(
        (explain([route('/docs/:section?')], '/docs')['matched_routes']
            as List),
        hasLength(1),
      );
      expect(
        (explain([route('/archive/:rest+')], '/archive/a/b')['matched_routes']
                as List)
            .single['params'],
        {'rest': 'a/b'},
      );
    });

    test('single wildcard cannot consume multiple segments', () {
      expect(
        explain([route('/files/*')], '/files/a')['matched_routes'],
        hasLength(1),
      );
      expect(
        explain([route('/files/*')], '/files/a/b')['matched_routes'],
        isEmpty,
      );
      expect(
        (explain([route('/files/**:slug')], '/files/a/b')['matched_routes']
                as List)
            .single['params'],
        {'slug': 'a/b'},
      );
    });

    test('static routes win and case sensitivity comes from config', () {
      final entries = [route('/users/:id'), route('/users/me')];
      expect(
        (explain(entries, '/users/me')['matched_routes'] as List)
            .single['path'],
        '/users/me',
      );
      expect(explain(entries, '/USERS/me')['matched_routes'], isEmpty);
      config = config.copyWith(caseSensitive: false);
      expect(explain(entries, '/USERS/me')['matched_routes'], hasLength(1));
    });

    test(
      'scopes use normalized catch-alls, method filters, and runtime order',
      () {
        final entries = [
          route('/users/:id'),
          ScanEntry.globalMiddleware(
            MiddlewareEntry(filePath: '/global.dart', path: '/**'),
          ),
          ScanEntry.scopedMiddleware(
            MiddlewareEntry(filePath: '/scoped.dart', path: '/users/:id/**'),
          ),
          ScanEntry.scopedMiddleware(
            MiddlewareEntry(
              filePath: '/post.dart',
              path: '/users/**',
              method: HttpMethod.post,
            ),
          ),
          ScanEntry.scopedError(
            ErrorEntry(filePath: '/root_error.dart', path: '/**'),
          ),
          ScanEntry.scopedError(
            ErrorEntry(filePath: '/scoped_error.dart', path: '/users/:id/**'),
          ),
          ScanEntry.scopedError(
            ErrorEntry(
              filePath: '/post_error.dart',
              path: '/users/**',
              method: HttpMethod.post,
            ),
          ),
        ];
        final result = explain(entries, '/users/42');
        expect((result['middleware_chain'] as List).map((e) => e['file']), [
          '/global.dart',
          '/scoped.dart',
        ]);
        expect((result['error_handlers'] as List).map((e) => e['file']), [
          '/scoped_error.dart',
          '/root_error.dart',
        ]);
        expect(
          explain(entries, '/users2/42')['middleware_chain'],
          hasLength(1),
        );
      },
    );

    test('fallback uses HEAD to GET fallback after ordinary routes', () {
      final fallback = ScanEntry.fallback(
        RouteEntry(
          filePath: '/fallback.dart',
          path: '/**:slug',
          method: HttpMethod.get,
          wildcardParam: 'slug',
        ),
      );
      final result = explain([fallback], '/missing/path', method: 'HEAD');
      expect(
        (result['matched_routes'] as List).single['file'],
        '/fallback.dart',
      );
      // Runtime fallback receives no handler-match params.
      expect((result['matched_routes'] as List).single['params'], isEmpty);
      expect(
        (explain([route('/users'), fallback], '/users')['matched_routes']
                as List)
            .single['path'],
        '/users',
      );
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
          ErrorEntry(filePath: '/fake/routes/_error.dart', path: '/**'),
        ),
      ]);

      final result = handleToolCall('spry.list_error_handlers', null, ps);
      final errors = result as List<dynamic>;

      expect(errors.length, 1);
      expect(errors[0]['path'], '/**');
    });

    test('explain_route matches route and collects middleware', () {
      final ps = newState([
        ScanEntry.route(
          RouteEntry(
            filePath: '/fake/routes/users/[id].dart',
            path: '/users/:id',
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
          ErrorEntry(filePath: '/fake/routes/_error.dart', path: '/**'),
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

    test('OpenAPI status resolves route and local artifact paths', () {
      for (final output in [
        OpenAPIOutput.route('api/spec.json'),
        OpenAPIOutput.local('schema/spec.json'),
      ]) {
        config = BuildConfig(
          rootDir: '/fake/project',
          publicDir: 'static',
          openapi: OpenAPIConfig(
            document: OpenAPIDocumentConfig(
              info: OpenAPIInfo(title: 'Test', version: '1'),
            ),
            output: output,
            ui: Scalar(),
          ),
        );
        final result =
            handleToolCall('spry.get_openapi_status', null, newState([]))
                as Map;
        final expected = output.type == 'route'
            ? p.join('static', 'api', 'spec.json')
            : p.join('schema', 'spec.json');
        expect(result['output_path'], expected);
        expect(result['artifact_path'], p.join(config.rootDir, expected));
        expect(result['configured_output_path'], output.path);
        expect(result['ui_route'], output.type == 'route' ? '/_docs' : isNull);
      }
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

    test('lists and counts the scanned root fallback', () {
      final state = newState([
        route('/users'),
        ScanEntry.fallback(
          RouteEntry(filePath: '/routes/[...].dart', path: '/**', method: null),
        ),
      ]);
      final listed = handleToolCall('spry.list_routes', null, state) as List;
      expect(listed, hasLength(2));
      expect(listed.last['file'], '/routes/[...].dart');
      final info = handleToolCall('spry.get_project_info', null, state) as Map;
      expect(info['route_count'], 2);
    });

    test(
      'resolves client package and library directories like the builder',
      () {
        for (final client in [
          ClientConfig(),
          ClientConfig(pkgDir: 'sdk', output: 'src'),
        ]) {
          config = config.copyWith(client: client);
          final status =
              handleToolCall('spry.get_client_status', null, newState([]))
                  as Map;
          final pkg = p.normalize(p.absolute(config.rootDir, client.pkgDir));
          expect(status['pkg_dir'], pkg);
          expect(
            status['output_dir'],
            p.normalize(p.absolute(pkg, client.output)),
          );
        }
      },
    );

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
