import 'package:path/path.dart' as p;
import 'package:spry/spry.dart' show HttpMethod;
import 'package:spry/src/builder/config.dart';
import 'package:spry/src/builder/scan_entry.dart';
import 'package:spry/src/builder/scanner.dart';
import 'package:spry/src/builder/scanner_semantics.dart';
import 'package:test/test.dart';

void main() {
  group('scan', () {
    test(
      'preserves exported openapi alias types in semantic contracts',
      () async {
        final context = ResolvedScannerContext(_fixture('with_openapi'));
        addTearDown(context.dispose);

        final unit = await context.resolvedUnit(
          p.join(_fixture('with_openapi'), 'routes', 'index.dart'),
        );
        final contracts = await context.contractsFor(unit);

        expect(
          contracts.openApiTypeNamed('OpenAPICallback')?.getDisplayString(),
          'Map<String, OpenAPIPathItem>',
        );
      },
    );

    test(
      'normalizes exported openapi alias elements when resolving names',
      () async {
        final context = ResolvedScannerContext(_fixture('with_openapi'));
        addTearDown(context.dispose);

        final unit = await context.resolvedUnit(
          p.join(_fixture('with_openapi'), 'routes', 'index.dart'),
        );
        final contracts = await context.contractsFor(unit);

        expect(
          contracts.openApiNameFor(
            contracts.openApiElementNamed('OpenAPICallback'),
          ),
          'OpenAPICallback',
        );
      },
    );

    test('discovers routes, middleware, errors, hooks and fallback', () async {
      final root = _fixture('complete');
      final tree = await _scanFixture(root);

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

    test('preserves deterministic recursive route discovery order', () async {
      final root = _fixture('complete');
      final tree = await _scanFixture(root);

      expect(
        tree.routes.map(
          (it) => p.relative(it.filePath, from: p.join(root, 'routes')),
        ),
        ['about.get.dart', 'index.dart', p.join('users', '[id].dart')],
      );
    });

    test('supports expressive route segment syntax', () async {
      final tree = await _scanFixture(_fixture('expressive'));

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

    test(
      'supports all method suffixes for global and scoped middleware',
      () async {
        final tree = await _scanFixture(_fixture('middleware_methods'));

        expect(tree.globalMiddleware, hasLength(7));
        expect(
          tree.globalMiddleware.map(
            (it) => (it.path, it.method, p.basename(it.filePath)),
          ),
          containsAll([
            ('/**', HttpMethod.get, '01_auth.get.dart'),
            ('/**', HttpMethod.post, '02_auth.post.dart'),
            ('/**', HttpMethod.put, '03_auth.put.dart'),
            ('/**', HttpMethod.patch, '04_auth.patch.dart'),
            ('/**', HttpMethod.delete, '05_auth.delete.dart'),
            ('/**', HttpMethod.head, '06_auth.head.dart'),
            ('/**', HttpMethod.options, '07_auth.options.dart'),
          ]),
        );

        expect(tree.scopedMiddleware, hasLength(7));
        expect(
          tree.scopedMiddleware.map(
            (it) => (it.path, it.method, p.basename(it.filePath)),
          ),
          containsAll([
            ('/admin/**', HttpMethod.get, '_middleware.get.dart'),
            ('/admin/**', HttpMethod.post, '_middleware.post.dart'),
            ('/admin/**', HttpMethod.put, '_middleware.put.dart'),
            ('/admin/**', HttpMethod.patch, '_middleware.patch.dart'),
            ('/admin/**', HttpMethod.delete, '_middleware.delete.dart'),
            ('/admin/**', HttpMethod.head, '_middleware.head.dart'),
            ('/admin/**', HttpMethod.options, '_middleware.options.dart'),
          ]),
        );
      },
    );

    test('ignores hook names in comments, strings and method calls', () async {
      final root = _fixture('false_positive_hooks');
      final tree = await _scanFixture(root);

      expect(tree.hooks, isNotNull);
      expect(tree.hooks!.hasOnStart, isFalse);
      expect(tree.hooks!.hasOnStop, isFalse);
      expect(tree.hooks!.hasOnError, isFalse);
    });

    test('rejects duplicate normalized routes', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('duplicate_routes'))).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects duplicate param names inside one route', () async {
      expect(
        () => scan(
          BuildConfig(rootDir: _fixture('duplicate_param_names')),
        ).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects param-name drift on the same normalized route', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('param_name_drift'))).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects conflicting catch-all files in the same directory', () async {
      expect(
        () => scan(
          BuildConfig(rootDir: _fixture('conflicting_catch_all')),
        ).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects named catch-all param-name drift', () async {
      expect(
        () => scan(
          BuildConfig(rootDir: _fixture('catch_all_name_drift')),
        ).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('preserves literal index directories for scoped handlers', () async {
      final tree = await _scanFixture(_fixture('scoped_index_dir'));

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
        () => scan(
          BuildConfig(rootDir: _fixture('non_terminal_catch_all')),
        ).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('allows catch-all directories when index.dart is terminal', () async {
      final tree = await _scanFixture(_fixture('catch_all_index_dir'));

      expect(tree.routes.map((it) => (it.path, p.basename(it.filePath))), [
        ('/docs/**:slug', 'index.dart'),
      ]);
    });

    test('captures top-level openapi metadata on route entries', () async {
      final tree = await _scanFixture(_fixture('with_openapi'));

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

    test('captures dot-shorthand openapi metadata on route entries', () async {
      final tree = await _scanFixture(_fixture('with_openapi_dot_shorthand'));

      final indexRoute = tree.routes.singleWhere((route) => route.path == '/');
      expect(indexRoute.openapi, isNotNull);
      expect(indexRoute.openapi!['summary'], 'Home');
      expect(indexRoute.openapi!['x-spry-openapi-global-components'], {
        'securitySchemes': {
          'apiKey': {'type': 'apiKey', 'name': 'x-api-key', 'in': 'header'},
        },
      });
      expect(indexRoute.openapi!['responses'], {
        '200': {
          'description': 'OK',
          'content': {
            'application/json': {
              'schema': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'id': {'type': 'string'},
                  },
                },
              },
            },
          },
        },
      });
    });

    test('accepts openapi typedef constructor aliases', () async {
      final tree = await _scanFixture(_fixture('with_openapi_alias'));

      final indexRoute = tree.routes.singleWhere((route) => route.path == '/');
      expect(indexRoute.openapi?['summary'], 'Alias default constructor');
    });

    test('accepts typed openapi typedef dot-shorthand constructors', () async {
      final tree = await _scanFixture(_fixture('with_openapi_alias_typed'));

      final indexRoute = tree.routes.singleWhere((route) => route.path == '/');
      expect(
        indexRoute.openapi?['summary'],
        'Alias typed dot shorthand constructor',
      );
    });

    test('accepts openapi wrappers via representation truth source', () async {
      final tree = await _scanFixture(_fixture('with_openapi_subtypes'));

      final indexRoute = tree.routes.singleWhere((route) => route.path == '/');
      expect(indexRoute.openapi?['summary'], 'Subtype constructor');
      expect(indexRoute.openapi?['responses'], {
        '200': {
          'description': 'OK',
          'content': {
            'application/json': {
              'schema': {
                'type': 'object',
                'properties': {
                  'id': {'type': 'string'},
                },
              },
            },
          },
        },
      });
    });

    test('accepts openapi ref typedef aliases', () async {
      final tree = await _scanFixture(_fixture('with_openapi_ref_alias'));

      final indexRoute = tree.routes.singleWhere((route) => route.path == '/');
      expect(indexRoute.openapi?['summary'], 'Ref alias constructor');
      expect(indexRoute.openapi?['responses'], {
        '200': {
          'description': 'OK',
          'content': {
            'application/json': {
              'schema': {
                'type': 'object',
                'properties': {
                  'id': {'type': 'string'},
                },
              },
            },
          },
        },
      });
    });

    test('supports deeply nested reusable openapi child values', () async {
      final tree = await _scanFixture(_fixture('with_openapi_deep_reuse'));

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
        final tree = await _scanFixture(_fixture('valid_handler_alias'));

        expect(tree.routes.map((it) => (it.path, it.method)), [('/', null)]);
      },
    );

    test(
      'rejects fake local OpenAPI types that do not come from Spry',
      () async {
        await expectLater(
          scan(BuildConfig(rootDir: _fixture('fake_openapi'))).drain(),
          throwsA(isA<RouteScanException>()),
        );
      },
    );

    test(
      'rejects fake openapi implementations that only satisfy assignability',
      () async {
        await expectLater(
          scan(
            BuildConfig(rootDir: _fixture('fake_openapi_implements')),
          ).drain(),
          throwsA(isA<RouteScanException>()),
        );
      },
    );

    test(
      'rejects fake openapi representation subtypes that do not forward to Spry contracts',
      () async {
        await expectLater(
          scan(
            BuildConfig(
              rootDir: _fixture('fake_openapi_representation_subtypes'),
            ),
          ).drain(),
          throwsA(isA<RouteScanException>()),
        );
      },
    );

    test('rejects raw top-level openapi maps', () async {
      await expectLater(
        scan(BuildConfig(rootDir: _fixture('raw_openapi_literal'))).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test(
      'injects default responses when openapi annotation omits responses',
      () async {
        final tree = await _scanFixture(_fixture('openapi_missing_responses'));
        final route = tree.routes.first;
        expect(route.openapi, isNotNull);
        expect(route.openapi!['responses'], {
          'default': {'description': ''},
        });
      },
    );

    test('rejects invalid route handler signatures during scan', () async {
      await expectLater(
        scan(
          BuildConfig(rootDir: _fixture('invalid_handler_signature')),
        ).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects invalid middleware signatures during scan', () async {
      await expectLater(
        scan(
          BuildConfig(rootDir: _fixture('invalid_middleware_signature')),
        ).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects invalid error handler signatures during scan', () async {
      await expectLater(
        scan(BuildConfig(rootDir: _fixture('invalid_error_signature'))).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects invalid hooks signatures during scan', () async {
      await expectLater(
        scan(BuildConfig(rootDir: _fixture('invalid_hooks_signature'))).drain(),
        throwsA(isA<RouteScanException>()),
      );
    });
  });
}

String _fixture(String name) {
  return p.normalize(p.absolute('test', 'fixtures', 'scanner', name));
}

Future<_ScannedProject> _scanFixture(String root) async {
  final routes = <RouteEntry>[];
  final globalMiddleware = <MiddlewareEntry>[];
  final scopedMiddleware = <MiddlewareEntry>[];
  final scopedErrors = <ErrorEntry>[];
  RouteEntry? fallback;
  HooksEntry? hooks;

  await for (final entry in scan(BuildConfig(rootDir: root))) {
    switch (entry.type) {
      case ScanEntryType.route:
        routes.add(entry.route!);
      case ScanEntryType.globalMiddleware:
        globalMiddleware.add(entry.middleware!);
      case ScanEntryType.scopedMiddleware:
        scopedMiddleware.add(entry.middleware!);
      case ScanEntryType.scopedError:
        scopedErrors.add(entry.error!);
      case ScanEntryType.fallback:
        fallback = entry.route;
      case ScanEntryType.hooks:
        hooks = entry.hooks;
    }
  }

  return _ScannedProject(
    routes: routes,
    globalMiddleware: globalMiddleware,
    scopedMiddleware: scopedMiddleware,
    scopedErrors: scopedErrors,
    fallback: fallback,
    hooks: hooks,
  );
}

final class _ScannedProject {
  const _ScannedProject({
    required this.routes,
    required this.globalMiddleware,
    required this.scopedMiddleware,
    required this.scopedErrors,
    required this.fallback,
    required this.hooks,
  });

  final List<RouteEntry> routes;
  final List<MiddlewareEntry> globalMiddleware;
  final List<MiddlewareEntry> scopedMiddleware;
  final List<ErrorEntry> scopedErrors;
  final RouteEntry? fallback;
  final HooksEntry? hooks;
}
