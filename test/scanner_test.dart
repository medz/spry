import 'package:path/path.dart' as p;
import 'package:spry/spry.dart' show HttpMethod;
import 'package:spry/src/builder/config.dart';
import 'package:spry/src/builder/scanner.dart';
import 'package:test/test.dart';

void main() {
  group('scan', () {
    test('discovers routes, middleware, errors, hooks and fallback', () async {
      final root = _fixture('complete');
      final tree = await scan(BuildConfig(rootDir: root));

      expect(tree.hooks, isNotNull);
      expect(tree.hooks!.filePath, p.join(root, 'hooks.dart'));
      expect(tree.hooks!.hasOnStart, isTrue);
      expect(tree.hooks!.hasOnStop, isFalse);
      expect(tree.hooks!.hasOnError, isFalse);
      expect(
        tree.globalMiddleware.map(
          (it) => (it.path, it.method, p.basename(it.filePath)),
        ),
        [
          ('/**', null, '01_logger.dart'),
          ('/**', HttpMethod.get, '02_auth.get.dart'),
        ],
      );

      expect(
        tree.routes.map((it) => (it.path, it.method, p.basename(it.filePath))),
        containsAll([
          ('/', null, 'index.dart'),
          ('/about', HttpMethod.get, 'about.get.dart'),
          ('/users/:id', null, '[id].dart'),
        ]),
      );

      expect(
        tree.scopedMiddleware.map(
          (it) => (it.path, it.method, p.basename(it.filePath)),
        ),
        [
          ('/**', null, '_middleware.dart'),
          ('/users/**', HttpMethod.get, '_middleware.get.dart'),
        ],
      );
      expect(
        tree.scopedErrors.map(
          (it) => (it.path, it.method, p.basename(it.filePath)),
        ),
        [
          ('/users/**', null, '_error.dart'),
          ('/users/**', HttpMethod.get, '_error.get.dart'),
        ],
      );

      expect(tree.fallback, isNotNull);
      expect(tree.fallback!.path, '/**:slug');
      expect(tree.fallback!.wildcardParam, 'slug');
    });

    test('supports expressive route segment syntax', () async {
      final tree = await scan(BuildConfig(rootDir: _fixture('expressive')));

      expect(
        tree.routes.map((it) => (it.path, it.method, p.basename(it.filePath))),
        containsAll([
          ('/users/*', null, '[_].dart'),
          ('/users/:id([0-9]+)', null, '[id([0-9]+)].dart'),
          ('/files/:name.:ext', null, '[name].[ext].dart'),
          ('/posts/post-:id.json', HttpMethod.get, 'post-[id].json.get.dart'),
          ('/docs/:section?', null, '[[section]].dart'),
          ('/assets/:path+', null, '[...path+].dart'),
          ('/archive/:rest*', null, '[[...rest]].dart'),
        ]),
      );
    });

    test('ignores hook names in comments, strings and method calls', () async {
      final root = _fixture('false_positive_hooks');
      final tree = await scan(BuildConfig(rootDir: root));

      expect(tree.hooks, isNotNull);
      expect(tree.hooks!.hasOnStart, isFalse);
      expect(tree.hooks!.hasOnStop, isFalse);
      expect(tree.hooks!.hasOnError, isFalse);
    });

    test('rejects duplicate normalized routes', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('duplicate_routes'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects duplicate param names inside one route', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('duplicate_param_names'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects param-name drift on the same normalized route', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('param_name_drift'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects conflicting catch-all files in the same directory', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('conflicting_catch_all'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects named catch-all param-name drift', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('catch_all_name_drift'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('preserves literal index directories for scoped handlers', () async {
      final tree = await scan(
        BuildConfig(rootDir: _fixture('scoped_index_dir')),
      );

      expect(
        tree.scopedMiddleware.map((it) => (it.path, p.basename(it.filePath))),
        [('/index/**', '_middleware.dart')],
      );
      expect(
        tree.scopedErrors.map((it) => (it.path, p.basename(it.filePath))),
        [('/index/**', '_error.dart')],
      );
    });

    test('rejects catch-all segments that are not terminal', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('non_terminal_catch_all'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('allows catch-all directories when index.dart is terminal', () async {
      final tree = await scan(
        BuildConfig(rootDir: _fixture('catch_all_index_dir')),
      );

      expect(tree.routes.map((it) => (it.path, p.basename(it.filePath))), [
        ('/docs/**:slug', 'index.dart'),
      ]);
    });

    test('captures top-level openapi metadata on route entries', () async {
      final tree = await scan(BuildConfig(rootDir: _fixture('with_openapi')));

      final indexRoute = tree.routes.singleWhere((route) => route.path == '/');
      expect(indexRoute.openapi, isNotNull);
      expect(indexRoute.openapi!['summary'], 'Home');
      expect(indexRoute.openapi!['deprecated'], isFalse);
      expect(indexRoute.openapi!['tags'], ['site', 'home']);
      expect(indexRoute.openapi!['responses'], {
        '200': {
          'description': 'OK',
          'content': {
            'application/json': {
              'schema': {
                'type': 'array',
                'items': {'type': 'string'},
              },
            },
          },
        },
      });

      final aboutRoute = tree.routes.singleWhere(
        (route) => route.path == '/about',
      );
      expect(aboutRoute.openapi, isNull);
    });

    test('supports deeply nested reusable openapi child values', () async {
      final tree = await scan(
        BuildConfig(rootDir: _fixture('with_openapi_deep_reuse')),
      );

      final indexRoute = tree.routes.singleWhere((route) => route.path == '/');
      expect(indexRoute.openapi, isNotNull);
      expect(indexRoute.openapi!['summary'], 'Create a user');
      expect(
        indexRoute.openapi!['description'],
        'Deeply reusable OpenAPI metadata.',
      );
      expect(indexRoute.openapi!['operationId'], 'createUser');
      expect(indexRoute.openapi!['externalDocs'], {
        'url': 'https://example.com/docs/users',
        'description': 'More user docs',
      });
      expect(indexRoute.openapi!['parameters'], [
        {
          'schema': {
            'type': 'string',
            'description': 'Stable user identifier.',
          },
          'description': 'User identifier.',
          'name': 'id',
          'in': 'path',
          'required': true,
        },
      ]);
      expect(indexRoute.openapi!['requestBody'], {
        'content': {
          'application/json': {
            'schema': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string'},
              },
            },
          },
        },
        'required': true,
      });
      expect(indexRoute.openapi!['responses'], {
        '201': {
          'description': 'Created user',
          'headers': {
            'Location': {
              'schema': {'type': 'string'},
              'description': 'Canonical user URL.',
            },
          },
          'content': {
            'application/json': {
              'schema': {
                'type': 'object',
                'properties': {
                  'id': {r'$ref': '#/components/schemas/UserId'},
                  'name': {'type': 'string'},
                },
              },
              'examples': {
                'default': {
                  'summary': 'Created user example',
                  'value': {'id': 'u_1', 'name': 'Ada'},
                },
              },
            },
          },
          'links': {
            'self': {
              'operationId': 'getUser',
              'parameters': {'id': r'$response.body#/id'},
            },
          },
        },
      });
      expect(indexRoute.openapi!['callbacks'], {
        'userCreated': {
          r'{$request.body#/callbackUrl}': {
            'post': {
              'responses': {
                '202': {'description': 'Accepted'},
              },
            },
          },
        },
      });
      expect(indexRoute.openapi!['security'], [
        {'bearerAuth': []},
      ]);
      expect(indexRoute.openapi!['servers'], [
        {
          'url': 'https://{region}.example.com',
          'variables': {
            'region': {
              'default': 'cn',
              'enum': ['cn', 'us'],
            },
          },
        },
      ]);
      expect(indexRoute.openapi!['x-spry-openapi-global-components'], {
        'schemas': {
          'UserId': {
            'type': 'string',
            'description': 'Stable user identifier.',
          },
          'User': {
            'type': 'object',
            'properties': {
              'id': {r'$ref': '#/components/schemas/UserId'},
              'name': {'type': 'string'},
            },
          },
        },
        'securitySchemes': {
          'bearerAuth': {
            'type': 'http',
            'scheme': 'bearer',
            'bearerFormat': 'JWT',
          },
        },
      });
    });

    test(
      'accepts handler typedef aliases assignable to Spry contracts',
      () async {
        final tree = await scan(
          BuildConfig(rootDir: _fixture('valid_handler_alias')),
        );

        expect(tree.routes.map((it) => (it.path, it.method)), [('/', null)]);
      },
    );

    test(
      'rejects fake local OpenAPI types that do not come from Spry',
      () async {
        await expectLater(
          scan(BuildConfig(rootDir: _fixture('fake_openapi'))),
          throwsA(isA<RouteScanException>()),
        );
      },
    );

    test('rejects raw top-level openapi maps', () async {
      await expectLater(
        scan(BuildConfig(rootDir: _fixture('raw_openapi_literal'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects invalid route handler signatures during scan', () async {
      await expectLater(
        scan(BuildConfig(rootDir: _fixture('invalid_handler_signature'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects invalid middleware signatures during scan', () async {
      await expectLater(
        scan(BuildConfig(rootDir: _fixture('invalid_middleware_signature'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects invalid error handler signatures during scan', () async {
      await expectLater(
        scan(BuildConfig(rootDir: _fixture('invalid_error_signature'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects invalid hooks signatures during scan', () async {
      await expectLater(
        scan(BuildConfig(rootDir: _fixture('invalid_hooks_signature'))),
        throwsA(isA<RouteScanException>()),
      );
    });
  });
}

String _fixture(String name) {
  return p.normalize(p.absolute('test', 'fixtures', 'scanner', name));
}
