import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../bin/src/build.dart';

String _currentPackageVersion() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final version = RegExp(
    r'^version:\s*([^\s#]+)',
    multiLine: true,
  ).firstMatch(pubspec)?.group(1);
  if (version == null || version.isEmpty) {
    throw StateError('Failed to resolve package version for test assertions.');
  }
  return version;
}

void main() {
  final spryVersionConstraint = '^${_currentPackageVersion()}';

  group('runBuild', () {
    test(
      'writes a minimal client shell into the default package dir',
      () async {
        final root = await _copyFixture('no_hooks');
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

        final out = StringBuffer();
        final err = StringBuffer();
        final code = await runBuild(
          root.path,
          Args.parse(['client']),
          out,
          err,
        );

        expect(code, 0);
        expect(out.toString(), contains('Searching Spry config in'));
        expect(out.toString(), contains('Loading Spry config from'));
        expect(out.toString(), contains('Scanning route handlers:'));
        expect(out.toString(), contains('Building client source:'));
        expect(out.toString(), contains('🎉 Build completed successfully'));
        expect(out.toString(), isNot(contains('✓  built client')));
        expect(err.toString(), isEmpty);
        expect(
          File(
            p.join(root.path, '.spry', 'client', 'lib', 'client.dart'),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            p.join(root.path, '.spry', 'client', 'lib', 'client.dart'),
          ).readAsStringSync(),
          contains('class SpryClient extends BaseSpryClient'),
        );
        expect(
          File(
            p.join(root.path, '.spry', 'client', 'lib', 'client.dart'),
          ).readAsStringSync(),
          contains('SpryClient({required super.endpoint, super.headers});'),
        );
        expect(
          File(
            p.join(root.path, '.spry', 'client', 'pubspec.yaml'),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            p.join(root.path, '.spry', 'client', 'pubspec.yaml'),
          ).readAsStringSync(),
          contains('spry:'),
        );
        expect(
          File(
            p.join(root.path, '.spry', 'client', 'pubspec.yaml'),
          ).readAsStringSync(),
          contains('spry: $spryVersionConstraint'),
        );
      },
    );

    test('build client falls back to default client config when absent', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final out = StringBuffer();
      final err = StringBuffer();
      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        out,
        err,
      );

      expect(code, 0);
      expect(err.toString(), isEmpty);
      expect(
        File(
          p.join(root.path, '.spry', 'client', 'lib', 'client.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, '.spry', 'client', 'lib', 'routes.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, '.spry', 'client', 'lib', 'client.dart'),
        ).readAsStringSync(),
        contains('class SpryClient extends BaseSpryClient'),
      );
    });

    test('respects routesDir when generating client source paths', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await Directory(p.join(root.path, 'app', 'routes', 'users')).create(
        recursive: true,
      );
      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await File(
        p.join(root.path, 'app', 'routes', 'users', '[id].get.dart'),
      ).writeAsString('''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('user');
''');
      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(routesDir: 'app/routes', client: .new());
}
''');

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, '.spry', 'client', 'lib', 'routes', 'users', '[id].dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, '.spry', 'client', 'lib', 'params', 'users', '[id].dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(root.path, '.spry', 'client', 'lib', '..')).listSync(
          recursive: true,
        ).whereType<File>().map((it) => p.relative(it.path, from: p.join(root.path, '.spry', 'client', 'lib'))),
        isNot(anyElement(contains('../app/routes'))),
      );
    });

    test(
      'build also generates client output when client config is enabled',
      () async {
        final root = await _copyFixture('no_hooks');
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

        final out = StringBuffer();
        final err = StringBuffer();
        final code = await runBuild(root.path, Args.parse(const []), out, err);

        expect(code, 0);
        expect(err.toString(), isEmpty);
        expect(
          File(
            p.join(root.path, '.spry', 'client', 'lib', 'client.dart'),
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            p.join(root.path, '.spry', 'client', 'lib', 'client.dart'),
          ).readAsStringSync(),
          contains('class SpryClient extends BaseSpryClient'),
        );
      },
    );

    test('reports stream-driven progress for client builds', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      final out = StringBuffer();
      final err = StringBuffer();
      final code = await runBuild(root.path, Args.parse(['client']), out, err);

      final stdoutText = out.toString();
      expect(code, 0);
      expect(err.toString(), isEmpty);
      expect(stdoutText, contains('Searching Spry config in'));
      expect(stdoutText, contains('Loading Spry config from'));
      expect(stdoutText, contains('Scanning route handlers:'));
      expect(stdoutText, contains('Adding client dependencies'));
      expect(stdoutText, contains('Building client source:'));
      expect(stdoutText, contains('🎉 Build completed successfully'));
      expect(stdoutText, isNot(contains('Loaded Spry config from')));
      expect(stdoutText, isNot(contains('Added spry to')));
      expect(stdoutText, isNot(contains('Built client sources to')));
    });

    test(
      'reports stream-driven progress for builds with runtime, openapi, client, and target compile',
      () async {
        final root = await _copyFixture('no_hooks');
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';
import 'package:spry/openapi.dart';

void main() {
  defineSpryConfig(
    target: BuildTarget.exe,
    openapi: OpenAPIConfig(
      document: OpenAPIDocumentConfig(
        info: OpenAPIInfo(title: 'CLI Test API', version: '1.0.0'),
      ),
      output: .local('openapi.json'),
    ),
    client: .new(),
  );
}
''');

        await File(p.join(root.path, 'routes', 'index.get.dart')).writeAsString(
          '''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  responses: {
    '200': .inline(
      .new(
        description: 'OK',
        content: {
          'application/json': .new(
            schema: .object({'ok': .boolean()}),
          ),
        },
      ),
    ),
  },
);

Response handler(Event event) => .json({'ok': true});
''',
        );

        final out = StringBuffer();
        final err = StringBuffer();
        final code = await runBuild(
          root.path,
          Args.parse(const []),
          out,
          err,
          processRunner: _dartCompileStubRunner,
        );

        final stdoutText = out.toString();
        expect(code, 0);
        expect(err.toString(), isEmpty);
        expect(stdoutText, contains('Searching Spry config in'));
        expect(stdoutText, contains('Loading Spry config from'));
        expect(stdoutText, contains('Scanning route handlers:'));
        expect(stdoutText, contains('Building runtime source:'));
        expect(stdoutText, contains('Building OpenAPI schema to'));
        expect(stdoutText, contains('Adding client dependencies'));
        expect(stdoutText, contains('Building client source:'));
        expect(stdoutText, contains('Building target exe in'));
        expect(stdoutText, contains('🎉 Build completed successfully'));
        expect(stdoutText, isNot(contains('Loaded Spry config from')));
        expect(stdoutText, isNot(contains('Added spry to')));
        expect(stdoutText, isNot(contains('Built runtime routes(')));
        expect(stdoutText, isNot(contains('Built OpenAPI schema to')));
        expect(stdoutText, isNot(contains('Built client sources to')));
        expect(stdoutText, isNot(contains('Built target exe in')));
      },
    );

    test('resolves pkgDir relative to project root for client builds', () async {
      final workspace = await _createRepoTempDir(
        'spry_cli_client_pkgdir_test_',
      );
      final root = Directory(p.join(workspace.path, 'server'));
      final clientDir = Directory(p.join(workspace.path, 'client'));
      await root.create(recursive: true);
      await _copyDirectory(
        Directory(
          p.normalize(p.absolute('test', 'fixtures', 'generator', 'no_hooks')),
        ),
        root,
      );
      addTearDown(() async {
        if (await workspace.exists()) {
          await workspace.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    client: .new(
      pkgDir: '../client',
      output: 'generated',
      endpoint: 'https://api.example.com',
      headers: Headers({'x-client': 'web', 'x-version': '1'}),
    ),
  );
}
''');

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      expect(code, 0);
      expect(
        File(p.join(clientDir.path, 'generated', 'client.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(clientDir.path, 'generated', 'client.dart'),
        ).readAsStringSync(),
        contains('class SpryClient extends BaseSpryClient'),
      );
      expect(
        File(
          p.join(clientDir.path, 'generated', 'client.dart'),
        ).readAsStringSync(),
        contains("SpryClient({Uri? endpoint, super.headers})"),
      );
      expect(
        File(
          p.join(clientDir.path, 'generated', 'client.dart'),
        ).readAsStringSync(),
        isNot(contains("export 'package:spry/client.dart';")),
      );
      expect(
        File(
          p.join(clientDir.path, 'generated', 'client.dart'),
        ).readAsStringSync(),
        contains("endpoint: endpoint ?? Uri.parse('https://api.example.com')"),
      );
      expect(
        File(
          p.join(clientDir.path, 'generated', 'client.dart'),
        ).readAsStringSync(),
        contains(
          "@override\n  final globalHeaders = Headers({'x-client': 'web', 'x-version': '1'});",
        ),
      );
      expect(File(p.join(clientDir.path, 'pubspec.yaml')).existsSync(), isTrue);
      expect(
        File(p.join(clientDir.path, 'pubspec.yaml')).readAsStringSync(),
        contains('spry: $spryVersionConstraint'),
      );
    });

    test('generates client entry exports and SpryClient shape', () async {
      final built = await _buildRouteSkeletonClient();
      addTearDown(() async {
        if (await built.root.exists()) {
          await built.root.delete(recursive: true);
        }
      });

      expect(built.clientSource, contains("import 'routes.dart';"));
      expect(built.clientSource, contains("export 'routes.dart';"));
      expect(built.clientSource, contains("export 'params.dart';"));
      expect(
        built.clientSource,
        contains('class SpryClient extends BaseSpryClient {'),
      );
      expect(
        built.clientSource,
        isNot(contains('final class SpryClient extends BaseSpryClient {')),
      );
      expect(
        built.clientSource,
        contains('late final root = RootRoutes(this);'),
      );
      expect(
        built.clientSource,
        contains('late final health = HealthRoutes(this);'),
      );
      expect(
        built.clientSource,
        contains('late final users = UsersRoutes(this);'),
      );
      expect(built.routesLibrary, contains("export 'routes/index.dart';"));
      expect(built.routesLibrary, contains("export 'routes/health.dart';"));
      expect(
        built.routesLibrary,
        contains("export 'routes/users/index.dart';"),
      );
      expect(built.routesLibrary, contains("export 'routes/users/[id].dart';"));
      expect(
        built.routesLibrary,
        contains("export 'routes/users/[id]/profile/index.dart';"),
      );
      expect(built.paramsLibrary, contains("export 'params/users/[id].dart';"));
      expect(
        built.paramsLibrary,
        isNot(contains("export 'params/users/[id]/profile/index.dart';")),
      );
    });

    test('generates route helper classes for root, health, and users', () async {
      final built = await _buildRouteSkeletonClient();
      addTearDown(() async {
        if (await built.root.exists()) {
          await built.root.delete(recursive: true);
        }
      });

      expect(
        built.rootRoutesSource,
        contains('class RootRoutes extends ClientRoutes {'),
      );
      expect(built.rootRoutesSource, contains('RootRoutes(super.client);'));
      expect(
        built.rootRoutesSource,
        contains(
          'Future<Response> call({BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
      expect(built.rootRoutesSource, contains("const path = '/';"));
      expect(
        built.rootRoutesSource,
        contains('final requestHeaders = Headers();'),
      );
      expect(
        built.rootRoutesSource,
        isNot(contains('final BaseSpryClient client;')),
      );
      expect(
        built.rootRoutesSource,
        isNot(contains('final SpryClient client;')),
      );

      expect(
        built.healthRoutesSource,
        contains('class HealthRoutes extends ClientRoutes {'),
      );
      expect(built.healthRoutesSource, contains('HealthRoutes(super.client);'));

      expect(
        built.usersRoutesSource,
        contains('class UsersRoutes extends ClientRoutes {'),
      );
      expect(built.usersRoutesSource, contains('UsersRoutes(super.client);'));
      expect(built.usersRoutesSource, contains("import '[id].dart';"));
      expect(
        built.usersRoutesSource,
        contains('late final byId = UsersByIdRoutes(client);'),
      );
    });

    test(
      'generates users params and reuses them for nested profile routes',
      () async {
        final built = await _buildRouteSkeletonClient();
        addTearDown(() async {
          if (await built.root.exists()) {
            await built.root.delete(recursive: true);
          }
        });

        expect(
          built.usersByIdRoutesSource,
          contains("import '../../params/users/[id].dart';"),
        );
        expect(
          built.usersByIdRoutesSource,
          contains("import '[id]/profile/index.dart';"),
        );
        expect(
          built.usersByIdRoutesSource,
          contains('late final profile = UsersByIdProfileRoutes(client);'),
        );
        expect(
          built.usersByIdParamsSource,
          contains('class UsersByIdParams {'),
        );
        expect(
          built.usersByIdParamsSource,
          contains('const UsersByIdParams({required this.id});'),
        );
        expect(built.usersByIdParamsSource, contains('final String id;'));
        expect(
          built.usersByIdRoutesSource,
          contains(
            'Future<Response> call({required UsersByIdParams params, BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );
        expect(
          built.usersByIdRoutesSource,
          contains('final pathSegments = <String>['),
        );

        expect(
          built.usersByIdProfileRoutesSource,
          contains("import '../../../../params/users/[id].dart';"),
        );
        expect(
          built.usersByIdProfileRoutesSource,
          contains('class UsersByIdProfileRoutes extends ClientRoutes {'),
        );
        expect(
          built.usersByIdProfileRoutesSource,
          contains('UsersByIdProfileRoutes(super.client);'),
        );
        expect(built.usersByIdProfileParamsFile.existsSync(), isFalse);
        expect(
          built.usersByIdProfileRoutesSource,
          contains(
            'Future<Response> call({required UsersByIdParams params, BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );
      },
    );

    test(
      'generates focused params for optional, regex, repeated, remainder, and wildcard patterns',
      () async {
        final built = await _buildRouteSkeletonClient();
        addTearDown(() async {
          if (await built.root.exists()) {
            await built.root.delete(recursive: true);
          }
        });

        expect(
          built.paramsLibrary,
          contains("export 'params/patterns/optional/[[id]].dart';"),
        );
        expect(
          built.paramsLibrary,
          contains("export 'params/patterns/regex/[id([0-9]+)].dart';"),
        );

        expect(
          built.patternsOptionalParamsSource,
          contains('class PatternsOptionalByIdParams {'),
        );
        expect(
          built.patternsOptionalParamsSource,
          contains('const PatternsOptionalByIdParams({this.id});'),
        );
        expect(
          built.patternsOptionalParamsSource,
          contains('final String? id;'),
        );
        expect(
          built.patternsOptionalRoutesSource,
          contains(
            'Future<Response> call({PatternsOptionalByIdParams params = const PatternsOptionalByIdParams(), BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );

        expect(
          built.patternsRegexParamsSource,
          contains('class PatternsRegexByIdParams {'),
        );
        expect(
          built.patternsRegexParamsSource,
          contains('PatternsRegexByIdParams({required String id})'),
        );
        expect(
          built.patternsRegexParamsSource,
          contains("id = _validateId(id);"),
        );
        expect(
          built.patternsRegexParamsSource,
          contains("static final _idPattern = RegExp('^(?:[0-9]+)\\\$');"),
        );
        expect(
          built.patternsRegexParamsSource,
          contains(
            "throw ArgumentError.value(value, 'id', 'Must match /[0-9]+/.');",
          ),
        );

        expect(
          built.patternsRepeatedOneParamsSource,
          contains('class PatternsRepeatedOneByPathParams {'),
        );
        expect(
          built.patternsRepeatedOneParamsSource,
          contains(
            'PatternsRepeatedOneByPathParams({required List<String> path})',
          ),
        );
        expect(
          built.patternsRepeatedOneParamsSource,
          contains('final List<String> path;'),
        );
        expect(
          built.patternsRepeatedOneParamsSource,
          contains('path = _validatePath(path);'),
        );
        expect(
          built.patternsRepeatedOneParamsSource,
          contains('if (value.isEmpty) {'),
        );
        expect(
          built.patternsRepeatedOneParamsSource,
          contains(
            "throw ArgumentError.value(value, 'path', 'Must contain at least one segment.');",
          ),
        );

        expect(
          built.patternsRepeatedZeroParamsSource,
          contains('class PatternsRepeatedZeroByPathParams {'),
        );
        expect(
          built.patternsRepeatedZeroParamsSource,
          contains(
            'const PatternsRepeatedZeroByPathParams({this.path = const []});',
          ),
        );
        expect(
          built.patternsRepeatedZeroParamsSource,
          contains('final List<String> path;'),
        );
        expect(
          built.patternsRepeatedZeroRoutesSource,
          contains(
            'Future<Response> call({PatternsRepeatedZeroByPathParams params = const PatternsRepeatedZeroByPathParams(), BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );

        expect(
          built.patternsRemainderNamedParamsSource,
          contains('class PatternsRemainderNamedBySlugParams {'),
        );
        expect(
          built.patternsRemainderNamedParamsSource,
          contains(
            'const PatternsRemainderNamedBySlugParams({this.slug = const []});',
          ),
        );
        expect(
          built.patternsRemainderNamedParamsSource,
          contains('final List<String> slug;'),
        );
        expect(
          built.patternsRemainderNamedRoutesSource,
          contains(
            'Future<Response> call({PatternsRemainderNamedBySlugParams params = const PatternsRemainderNamedBySlugParams(), BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );

        expect(
          built.patternsRemainderUnnamedParamsSource,
          contains('class PatternsRemainderUnnamedSegmentParams {'),
        );
        expect(
          built.patternsRemainderUnnamedParamsSource,
          contains(
            'const PatternsRemainderUnnamedSegmentParams({this.segments = const []});',
          ),
        );
        expect(
          built.patternsRemainderUnnamedParamsSource,
          contains('final List<String> segments;'),
        );
        expect(
          built.patternsRemainderUnnamedRoutesSource,
          contains(
            'Future<Response> call({PatternsRemainderUnnamedSegmentParams params = const PatternsRemainderUnnamedSegmentParams(), BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );

        expect(
          built.patternsSingleWildcardParamsSource,
          contains('class PatternsSingleWildcardSegmentParams {'),
        );
        expect(
          built.patternsSingleWildcardParamsSource,
          contains(
            'const PatternsSingleWildcardSegmentParams({required this.segment});',
          ),
        );
        expect(
          built.patternsSingleWildcardParamsSource,
          contains('final String segment;'),
        );
        expect(
          built.patternsSingleWildcardRoutesSource,
          contains(
            'Future<Response> call({required PatternsSingleWildcardSegmentParams params, BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );
      },
    );

    test('adds spry dependency into an existing client pubspec', () async {
      final workspace = await _createRepoTempDir(
        'spry_cli_client_existing_pubspec_test_',
      );
      final root = Directory(p.join(workspace.path, 'server'));
      final clientDir = Directory(p.join(workspace.path, 'client'));
      await root.create(recursive: true);
      await clientDir.create(recursive: true);
      await _copyDirectory(
        Directory(
          p.normalize(p.absolute('test', 'fixtures', 'generator', 'no_hooks')),
        ),
        root,
      );
      addTearDown(() async {
        if (await workspace.exists()) {
          await workspace.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    client: .new(
      pkgDir: '../client',
      output: 'generated',
      endpoint: 'https://api.example.com',
    ),
  );
}
''');

      await File(p.join(clientDir.path, 'pubspec.yaml')).writeAsString('''
name: custom_client
publish_to: none
description: Hand-written client package.

environment:
  sdk: ^3.10.0
''');

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final pubspec = File(
        p.join(clientDir.path, 'pubspec.yaml'),
      ).readAsStringSync();

      expect(code, 0);
      expect(pubspec, contains('name: custom_client'));
      expect(pubspec, contains('description: Hand-written client package.'));
      expect(pubspec, contains('spry: $spryVersionConstraint'));
    });

    test('merges and extends generated params by path shape', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(root.path, 'routes', 'shared'),
      ).create(recursive: true);
      await Directory(
        p.join(root.path, 'routes', 'users', '[userId]', 'posts'),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      for (final (path, source) in [
        (
          p.join(root.path, 'routes', 'shared', '[id].get.dart'),
          '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('shared-get');
''',
        ),
        (
          p.join(root.path, 'routes', 'shared', '[id].post.dart'),
          '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('shared-post');
''',
        ),
        (
          p.join(root.path, 'routes', 'users', '[userId].get.dart'),
          '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('user');
''',
        ),
        (
          p.join(
            root.path,
            'routes',
            'users',
            '[userId]',
            'posts',
            '[postId].get.dart',
          ),
          '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('post');
''',
        ),
      ]) {
        await File(path).writeAsString(source);
      }

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final sharedRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'shared',
          '[id].dart',
        ),
      ).readAsStringSync();
      final sharedParamsSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'params',
          'shared',
          '[id].dart',
        ),
      ).readAsStringSync();
      final userParamsSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'params',
          'users',
          '[userId].dart',
        ),
      ).readAsStringSync();
      final userPostParamsSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'params',
          'users',
          '[userId]',
          'posts',
          '[postId].dart',
        ),
      ).readAsStringSync();

      expect(code, 0);
      expect(sharedParamsSource, contains('class SharedByIdParams {'));
      expect(
        sharedRoutesSource,
        contains(
          'Future<Response> get({required SharedByIdParams params, BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
      expect(
        sharedRoutesSource,
        contains(
          'Future<Response> post({required SharedByIdParams params, BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
      expect(userParamsSource, contains('class UsersByUserIdParams {'));
      expect(
        userPostParamsSource,
        contains(
          'class UsersByUserIdPostsByPostIdParams extends UsersByUserIdParams {',
        ),
      );
      expect(
        userPostParamsSource,
        contains(
          'const UsersByUserIdPostsByPostIdParams({required super.userId, required this.postId});',
        ),
      );
      expect(userPostParamsSource, contains('final String postId;'));
    });

    test('disambiguates sibling dynamic routes by route shape', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(root.path, 'routes', 'shared'),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      for (final (path, source) in [
        (
          p.join(root.path, 'routes', 'shared', '[id].get.dart'),
          '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('plain');
''',
        ),
        (
          p.join(root.path, 'routes', 'shared', '[id([0-9]+)].get.dart'),
          '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('regex');
''',
        ),
      ]) {
        await File(path).writeAsString(source);
      }

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final sharedRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'shared',
          'index.dart',
        ),
      ).readAsStringSync();

      expect(code, 0);
      expect(
        sharedRoutesSource,
        contains('late final byId = SharedByIdRoutes(client);'),
      );
      expect(
        sharedRoutesSource,
        contains('late final byIdRegex = SharedByIdRegexRoutes(client);'),
      );
    });

    test('mirrors source route file semantics for nested namespaces', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(
          root.path,
          'routes',
          'users',
          '[id]',
          'posts',
          '[postId]',
          'comments',
        ),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      for (final (path, source) in [
        (
          p.join(
            root.path,
            'routes',
            'users',
            '[id]',
            'posts',
            '[postId].get.dart',
          ),
          '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('post');
''',
        ),
        (
          p.join(
            root.path,
            'routes',
            'users',
            '[id]',
            'posts',
            '[postId]',
            'comments',
            '[commentId].get.dart',
          ),
          '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('comment');
''',
        ),
      ]) {
        await File(path).writeAsString(source);
      }

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final userRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'users',
          '[id]',
          'index.dart',
        ),
      ).readAsStringSync();
      final postsRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'users',
          '[id]',
          'posts',
          'index.dart',
        ),
      ).readAsStringSync();

      expect(code, 0);
      expect(
        File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'routes',
            'users',
            '[id]',
            'posts',
            'index.dart',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'routes',
            'users',
            '[id]',
            'posts',
            '[postId]',
            'comments',
            'index.dart',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'routes',
            'users',
            ':id',
            'posts',
            'index.dart',
          ),
        ).existsSync(),
        isFalse,
      );
      expect(userRoutesSource, contains("import 'posts/index.dart';"));
      expect(
        postsRoutesSource,
        isNot(contains("import '../../../../params/users/[id].dart';")),
      );
    });

    test('generates typed inputs for safe json request bodies', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(root.path, 'routes', 'users'),
      ).create(recursive: true);
      await Directory(
        p.join(root.path, 'routes', 'uploads'),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      await File(
        p.join(root.path, 'routes', 'users', 'index.post.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  requestBody: .inline(
    .new(
      required: true,
      content: {
        'application/json': .new(
          schema: .object({
            'name': .string(),
            'startsAt': .string(format: 'date-time'),
            'age': .integer(),
          }, requiredProperties: ['name', 'startsAt']),
        ),
      },
    ),
  ),
);

Response handler(Event _) => Response('created');
''');

      await File(
        p.join(root.path, 'routes', 'uploads', 'index.post.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  requestBody: .inline(
    .new(
      required: true,
      content: {
        'multipart/form-data': .new(
          schema: .object({'file': .string()}),
        ),
      },
    ),
  ),
);

Response handler(Event _) => Response('uploaded');
''');

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final inputsLibrarySource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'inputs.dart'),
      ).readAsStringSync();
      final userInputsSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'inputs',
          'users',
          'index.post.dart',
        ),
      ).readAsStringSync();
      final userRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'users',
          'index.dart',
        ),
      ).readAsStringSync();
      final uploadRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'uploads',
          'index.dart',
        ),
      ).readAsStringSync();

      expect(code, 0);
      expect(
        inputsLibrarySource,
        contains("export 'inputs/users/index.post.dart';"),
      );
      expect(userInputsSource, contains('class PostUsersInput {'));
      expect(
        userInputsSource,
        contains(
          'const PostUsersInput({required this.name, required this.startsAt, this.age});',
        ),
      );
      expect(userInputsSource, contains('final String name;'));
      expect(userInputsSource, contains('final DateTime startsAt;'));
      expect(userInputsSource, contains('final int? age;'));
      expect(
        userInputsSource,
        contains("startsAt: DateTime.parse(json['startsAt'] as String),"),
      );
      expect(
        userInputsSource,
        contains("'startsAt': startsAt.toIso8601String(),"),
      );
      expect(
        userRoutesSource,
        contains("import '../../inputs/users/index.post.dart';"),
      );
      expect(
        userRoutesSource,
        contains(
          'Future<Response> call({PostUsersInput? data, BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
      expect(
        userRoutesSource,
        contains(
          '.new(method: HttpMethod.post, headers: requestHeaders, body: body ?? data?.toJson())',
        ),
      );
      expect(
        uploadRoutesSource,
        contains(
          'Future<Response> call({BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
      expect(
        File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'inputs',
            'uploads',
            'index.post.dart',
          ),
        ).existsSync(),
        isFalse,
      );
    });

    test('reuses nested input types within one request body shape', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(root.path, 'routes', 'projects'),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      await File(
        p.join(root.path, 'routes', 'projects', 'index.post.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  requestBody: .inline(
    .new(
      required: true,
      content: {
        'application/json': .new(
          schema: .object({
            'owner': .object({
              'name': .string(),
              'address': .object({
                'city': .string(),
                'zip': .string(),
              }, requiredProperties: ['city', 'zip']),
            }, requiredProperties: ['name', 'address']),
            'reviewer': .object({
              'name': .string(),
              'address': .object({
                'city': .string(),
                'zip': .string(),
              }, requiredProperties: ['city', 'zip']),
            }, requiredProperties: ['name', 'address']),
            'watchers': .array(
              .object({
                'name': .string(),
                'address': .object({
                  'city': .string(),
                  'zip': .string(),
                }, requiredProperties: ['city', 'zip']),
              }, requiredProperties: ['name', 'address']),
            ),
          }, requiredProperties: ['owner', 'reviewer']),
        ),
      },
    ),
  ),
);

Response handler(Event _) => Response('created');
''');

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final inputSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'inputs',
          'projects',
          'index.post.dart',
        ),
      ).readAsStringSync();

      expect(code, 0);
      expect(inputSource, contains('class PostProjectsInput {'));
      expect(inputSource, contains('factory PostProjectsInput.fromJson('));
      expect(inputSource, contains('class PostProjectsOwnerInput {'));
      expect(inputSource, contains('factory PostProjectsOwnerInput.fromJson('));
      expect(inputSource, contains('class PostProjectsOwnerAddressInput {'));
      expect(inputSource, contains('final PostProjectsOwnerInput owner;'));
      expect(inputSource, contains('final PostProjectsOwnerInput reviewer;'));
      expect(
        inputSource,
        contains('final List<PostProjectsOwnerInput>? watchers;'),
      );
      expect(
        inputSource,
        contains(
          "owner: PostProjectsOwnerInput.fromJson(json['owner'] as Map<String, Object?>),",
        ),
      );
      expect(
        inputSource,
        contains(
          "reviewer: PostProjectsOwnerInput.fromJson(json['reviewer'] as Map<String, Object?>),",
        ),
      );
      expect(
        inputSource,
        contains(
          "final value => (value as List<Object?>).map((item) => PostProjectsOwnerInput.fromJson(item as Map<String, Object?>)).toList(growable: false),",
        ),
      );
      expect(inputSource, isNot(contains('class PostProjectsReviewerInput {')));
    });

    test('lifts global component refs into shared models', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(root.path, 'routes', 'projects'),
      ).create(recursive: true);
      await Directory(
        p.join(root.path, 'routes', 'teams'),
      ).create(recursive: true);
      await Directory(
        p.join(root.path, 'routes', 'participants'),
      ).create(recursive: true);
      await Directory(
        p.join(root.path, 'routes', '_shared'),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      await File(
        p.join(root.path, 'routes', '_shared', 'input_specs.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';

final participantComponents = OpenAPIComponents(
  schemas: {
    'Address': .object({
      'city': .string(),
      'zip': .string(),
    }, requiredProperties: ['city', 'zip']),
    'Participant': .object({
      'name': .string(),
      'joinedAt': .string(format: 'date-time'),
      'address': .ref('#/components/schemas/Address'),
    }, requiredProperties: ['name', 'joinedAt', 'address']),
  },
  requestBodies: {
    'ParticipantPayload': .inline(
      .new(
        required: true,
        content: {
          'application/json': .new(
            schema: .ref('#/components/schemas/Participant'),
          ),
        },
      ),
    ),
  },
);
''');

      await File(
        p.join(root.path, 'routes', 'projects', 'index.post.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

import '../_shared/input_specs.dart';

final openapi = OpenAPI(
  globalComponents: participantComponents,
  requestBody: .inline(
    .new(
      required: true,
      content: {
        'application/json': .new(
          schema: .object({
            'owner': .ref('#/components/schemas/Participant'),
            'reviewer': .ref('#/components/schemas/Participant'),
            'watchers': .array(.ref('#/components/schemas/Participant')),
          }, requiredProperties: ['owner', 'reviewer']),
        ),
      },
    ),
  ),
);

Response handler(Event _) => Response('ok');
''');

      await File(
        p.join(root.path, 'routes', 'teams', 'index.post.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

import '../_shared/input_specs.dart';

final openapi = OpenAPI(
  globalComponents: participantComponents,
  requestBody: .inline(
    .new(
      required: true,
      content: {
        'application/json': .new(
          schema: .object({
            'lead': .ref('#/components/schemas/Participant'),
            'backup': .object({
              'name': .string(),
              'joinedAt': .string(format: 'date-time'),
              'address': .ref('#/components/schemas/Address'),
            }, requiredProperties: ['name', 'joinedAt', 'address']),
            'members': .array(.ref('#/components/schemas/Participant')),
          }, requiredProperties: ['lead', 'backup']),
        ),
      },
    ),
  ),
);

Response handler(Event _) => Response('ok');
''');

      await File(
        p.join(root.path, 'routes', 'participants', 'index.post.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

import '../_shared/input_specs.dart';

final openapi = OpenAPI(
  globalComponents: participantComponents,
  requestBody: .ref('#/components/requestBodies/ParticipantPayload'),
);

Response handler(Event _) => Response('ok');
''');

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final projectsInputSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'inputs',
          'projects',
          'index.post.dart',
        ),
      ).readAsStringSync();
      final teamsInputSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'inputs',
          'teams',
          'index.post.dart',
        ),
      ).readAsStringSync();
      final participantsRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'participants',
          'index.dart',
        ),
      ).readAsStringSync();
      final modelsLibrarySource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'models.dart'),
      ).readAsStringSync();
      final participantModelSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'models',
          'participant.dart',
        ),
      ).readAsStringSync();
      final addressModelSource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'models', 'address.dart'),
      ).readAsStringSync();

      expect(code, 0);
      expect(modelsLibrarySource, contains("export 'models/address.dart';"));
      expect(
        modelsLibrarySource,
        contains("export 'models/participant.dart';"),
      );
      expect(addressModelSource, contains('class Address {'));
      expect(addressModelSource, contains('final String city;'));
      expect(addressModelSource, contains('final String zip;'));
      expect(participantModelSource, contains('class Participant {'));
      expect(participantModelSource, contains('final String name;'));
      expect(participantModelSource, contains('final DateTime joinedAt;'));
      expect(participantModelSource, contains('final Address address;'));
      expect(
        participantModelSource,
        contains("joinedAt: DateTime.parse(json['joinedAt'] as String),"),
      );
      expect(
        participantModelSource,
        contains("'joinedAt': joinedAt.toIso8601String(),"),
      );
      expect(projectsInputSource, contains('class PostProjectsInput {'));
      expect(projectsInputSource, contains('final Participant owner;'));
      expect(projectsInputSource, contains('final Participant reviewer;'));
      expect(
        projectsInputSource,
        contains('final List<Participant>? watchers;'),
      );
      expect(teamsInputSource, contains('class PostTeamsInput {'));
      expect(teamsInputSource, contains('final Participant lead;'));
      expect(teamsInputSource, contains('final Participant backup;'));
      expect(teamsInputSource, contains('final List<Participant>? members;'));
      expect(teamsInputSource, isNot(contains('class PostTeamsLeadInput {')));
      expect(
        teamsInputSource,
        isNot(contains('class PostTeamsLeadAddressInput {')),
      );
      expect(
        participantsRoutesSource,
        contains(
          'Future<Response> call({Participant? data, BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
      expect(
        File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'inputs',
            'participants',
            'index.post.dart',
          ),
        ).existsSync(),
        isFalse,
      );
    });

    test(
      'generates typed output sources for safe single success json responses',
      () async {
        final root = await _copyFixture('no_hooks');
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        await File(p.join(root.path, 'routes', 'index.dart')).delete();
        await Directory(
          p.join(root.path, 'routes', 'users'),
        ).create(recursive: true);
        await Directory(
          p.join(root.path, 'routes', 'uploads'),
        ).create(recursive: true);

        await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

        await File(p.join(root.path, 'routes', 'index.get.dart')).writeAsString(
          '''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  responses: {
    '200': .inline(
      .new(
        description: 'Users',
        content: {
          'application/json': .new(
            schema: .array(
              .object({
                'id': .string(),
                'name': .string(),
              }, requiredProperties: ['id', 'name']),
            ),
          ),
        },
      ),
    ),
  },
);

Response handler(Event _) => .json([
  {'id': 'u_1', 'name': 'Ada'},
]);
''',
        );

        await File(
          p.join(root.path, 'routes', 'users', '[id].get.dart'),
        ).writeAsString('''
// ignore_for_file: file_names

import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  responses: {
    '200': .inline(
      .new(
        description: 'User',
        content: {
          'application/json': .new(
            schema: .object({
              'id': .string(),
              'name': .string(),
            }, requiredProperties: ['id', 'name']),
          ),
        },
      ),
    ),
  },
);

Response handler(Event event) => .json({
  'id': event.params.required('id'),
  'name': 'Ada',
});
''');

        await File(
          p.join(root.path, 'routes', 'uploads', 'index.post.dart'),
        ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  responses: {
    '201': .inline(
      .new(
        description: 'Uploaded',
        content: {
          'text/plain': .new(schema: .string()),
        },
      ),
    ),
  },
);

Response handler(Event _) => Response('uploaded');
''');

        final code = await runBuild(
          root.path,
          Args.parse(['client']),
          StringBuffer(),
          StringBuffer(),
        );

        final outputsLibrarySource = File(
          p.join(root.path, '.spry', 'client', 'lib', 'outputs.dart'),
        ).readAsStringSync();
        final rootOutputSource = File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'outputs',
            'index.get.dart',
          ),
        ).readAsStringSync();
        final userOutputFile = File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'outputs',
            'users',
            '[id].get.dart',
          ),
        );
        final rootRoutesSource = File(
          p.join(root.path, '.spry', 'client', 'lib', 'routes', 'index.dart'),
        ).readAsStringSync();
        final userRoutesSource = File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'routes',
            'users',
            '[id].dart',
          ),
        ).readAsStringSync();
        final uploadRoutesSource = File(
          p.join(
            root.path,
            '.spry',
            'client',
            'lib',
            'routes',
            'uploads',
            'index.dart',
          ),
        ).readAsStringSync();

        expect(code, 0);
        expect(
          outputsLibrarySource,
          contains("export 'outputs/index.get.dart';"),
        );
        expect(
          outputsLibrarySource,
          isNot(contains("export 'outputs/users/[id].get.dart';")),
        );
        expect(rootOutputSource, contains('class GetRootItemOutput {'));
        expect(rootOutputSource, contains('class GetRootOutput {'));
        expect(
          rootOutputSource,
          contains('final List<GetRootItemOutput> data;'),
        );
        expect(
          rootOutputSource,
          contains('Response toResponse() => _response;'),
        );
        expect(userOutputFile.existsSync(), isFalse);
        expect(rootOutputSource, contains('final String name;'));
        expect(
          rootRoutesSource,
          contains(
            'Future<GetRootOutput> call({BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );
        expect(
          rootRoutesSource,
          contains('final response = await client.oxy.send(request);'),
        );
        expect(rootRoutesSource, contains('return GetRootOutput.fromJson('));
        expect(
          userRoutesSource,
          contains(
            'Future<GetRootItemOutput> call({required UsersByIdParams params, BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );
        expect(
          uploadRoutesSource,
          contains(
            'Future<Response> call({BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
          ),
        );
        expect(
          File(
            p.join(
              root.path,
              '.spry',
              'client',
              'lib',
              'outputs',
              'uploads',
              'index.post.dart',
            ),
          ).existsSync(),
          isFalse,
        );
      },
    );

    test('generates typed query helpers from openapi query parameters', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(root.path, 'routes', 'search'),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      await File(
        p.join(root.path, 'routes', 'search', 'index.get.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  parameters: [
    .inline(.query('q', required: true, schema: .string())),
    .inline(.query('page', schema: .integer())),
    .inline(.query('startsAt', schema: .string(format: 'date-time'))),
  ],
);

Response handler(Event _) => Response('ok');
''');

      await File(p.join(root.path, 'routes', 'health.get.dart')).writeAsString(
        '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('ok');
''',
      );

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final queriesLibrarySource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'queries.dart'),
      ).readAsStringSync();
      final searchQuerySource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'queries',
          'search',
          'index.get.dart',
        ),
      ).readAsStringSync();
      final searchRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'search',
          'index.dart',
        ),
      ).readAsStringSync();
      final healthRoutesSource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'routes', 'health.dart'),
      ).readAsStringSync();

      expect(code, 0);
      expect(
        queriesLibrarySource,
        contains("export 'queries/search/index.get.dart';"),
      );
      expect(
        searchQuerySource,
        contains('extension type GetSearchQuery._(URLSearchParams _)'),
      );
      expect(
        searchQuerySource,
        contains(
          'factory GetSearchQuery({required String q, int? page, DateTime? startsAt})',
        ),
      );
      expect(
        searchQuerySource,
        contains('factory GetSearchQuery.raw([Object? init])'),
      );
      expect(searchQuerySource, contains("'q': q"));
      expect(searchQuerySource, contains("'page': ?page?.toString()"));
      expect(
        searchQuerySource,
        contains("'startsAt': ?startsAt?.toIso8601String()"),
      );
      expect(
        searchRoutesSource,
        contains(
          'Future<Response> call({required GetSearchQuery query, BodyInit? body, Headers? headers}) async {',
        ),
      );
      expect(searchRoutesSource, contains("'\$path?\$query'"));
      expect(
        healthRoutesSource,
        contains(
          'Future<Response> call({BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
    });

    test('falls back to raw query when openapi query params are only partially supported', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(root.path, 'routes', 'search'),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      await File(
        p.join(root.path, 'routes', 'search', 'index.get.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  parameters: [
    .inline(.query('q', required: true, schema: .string())),
    .inline(
      .query(
        'tags',
        schema: .array(.string()),
      ),
    ),
  ],
);

Response handler(Event _) => Response('ok');
''');

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final queriesLibrarySource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'queries.dart'),
      ).readAsStringSync();
      final searchQueryFile = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'queries',
          'search',
          'index.get.dart',
        ),
      );
      final searchRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'search',
          'index.dart',
        ),
      ).readAsStringSync();

      expect(code, 0);
      expect(
        queriesLibrarySource,
        isNot(contains("export 'queries/search/index.get.dart';")),
      );
      expect(searchQueryFile.existsSync(), isFalse);
      expect(
        searchRoutesSource,
        contains(
          'Future<Response> call({BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
    });

    test('generates typed header helpers from openapi header parameters', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(p.join(root.path, 'routes', 'index.dart')).delete();
      await Directory(
        p.join(root.path, 'routes', 'profile'),
      ).create(recursive: true);

      await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

      await File(
        p.join(root.path, 'routes', 'profile', 'index.get.dart'),
      ).writeAsString('''
import 'package:spry/openapi.dart';
import 'package:spry/spry.dart';

final openapi = OpenAPI(
  parameters: [
    .inline(.header('x-api-key', required: true, schema: .string())),
    .inline(.header('x-request-id', schema: .string())),
    .inline(.header('x-starts-at', schema: .string(format: 'date-time'))),
  ],
);

Response handler(Event _) => Response('ok');
''');

      await File(p.join(root.path, 'routes', 'health.get.dart')).writeAsString(
        '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('ok');
''',
      );

      final code = await runBuild(
        root.path,
        Args.parse(['client']),
        StringBuffer(),
        StringBuffer(),
      );

      final headersLibrarySource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'headers.dart'),
      ).readAsStringSync();
      final profileHeadersSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'headers',
          'profile',
          'index.get.dart',
        ),
      ).readAsStringSync();
      final profileRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'profile',
          'index.dart',
        ),
      ).readAsStringSync();
      final healthRoutesSource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'routes', 'health.dart'),
      ).readAsStringSync();

      expect(code, 0);
      expect(
        headersLibrarySource,
        contains("export 'headers/profile/index.get.dart';"),
      );
      expect(
        profileHeadersSource,
        contains('extension type GetProfileHeaders._(Headers _)'),
      );
      expect(
        profileHeadersSource,
        contains(
          'factory GetProfileHeaders({required String xApiKey, String? xRequestId, DateTime? xStartsAt})',
        ),
      );
      expect(
        profileHeadersSource,
        contains('factory GetProfileHeaders.raw([Object? init])'),
      );
      expect(profileHeadersSource, contains("'x-api-key': xApiKey"));
      expect(profileHeadersSource, contains("'x-request-id': ?xRequestId"));
      expect(
        profileHeadersSource,
        contains("'x-starts-at': ?xStartsAt?.toIso8601String()"),
      );
      expect(
        profileRoutesSource,
        contains(
          'Future<Response> call({required GetProfileHeaders headers, BodyInit? body, URLSearchParams? query}) async {',
        ),
      );
      expect(
        profileRoutesSource,
        contains('for (final MapEntry(:key, :value) in headers.entries()) {'),
      );
      expect(
        healthRoutesSource,
        contains(
          'Future<Response> call({BodyInit? body, Headers? headers, URLSearchParams? query}) async {',
        ),
      );
    });

    test('writes generated files into .spry', () async {
      final root = await _copyFixture('complete');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final out = StringBuffer();
      final err = StringBuffer();
      final code = await runBuild(root.path, Args.parse(const []), out, err);

      expect(code, 0);
      expect(out.toString(), contains('🎉 Build completed successfully'));
      expect(err.toString(), isEmpty);
      expect(
        File(p.join(root.path, '.spry', 'src', 'app.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'src', 'hooks.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'src', 'main.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'public.dart')).existsSync(),
        isFalse,
      );
    });

    test('respects output override', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final code = await runBuild(
        root.path,
        Args.parse(['--output', 'generated/runtime'], string: ['output']),
        StringBuffer(),
        StringBuffer(),
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, 'generated', 'runtime', 'src', 'app.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, 'generated', 'runtime', 'src', 'hooks.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, 'generated', 'runtime', 'src', 'main.dart'),
        ).existsSync(),
        isTrue,
      );
    });

    test('uses config file override', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'build.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'outputDir': 'dist/runtime'}));
}
''');

      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/build.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, 'dist', 'runtime', 'src', 'app.dart'),
        ).existsSync(),
        isTrue,
      );
    });

    test('resolves project root from root override', () async {
      final workspace = await _createRepoTempDir('spry_cli_root_test_');
      final root = Directory(p.join(workspace.path, 'example'));
      await root.create(recursive: true);
      await _copyDirectory(
        Directory(
          p.normalize(p.absolute('test', 'fixtures', 'generator', 'no_hooks')),
        ),
        root,
      );
      addTearDown(() async {
        if (await workspace.exists()) {
          await workspace.delete(recursive: true);
        }
      });

      final code = await runBuild(
        workspace.path,
        Args.parse(['--root', 'example'], string: ['root']),
        StringBuffer(),
        StringBuffer(),
      );

      expect(code, 0);
      expect(
        File(p.join(root.path, '.spry', 'src', 'app.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(workspace.path, '.spry', 'src', 'app.dart')).existsSync(),
        isFalse,
      );
    });

    test('recreates output dir while preserving tools cache', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'cloudflare.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'cloudflare'}));
}
''');

      final outputDir = Directory(p.join(root.path, '.spry'));
      await outputDir.create(recursive: true);
      await File(p.join(outputDir.path, 'random.txt')).writeAsString('// old');
      await Directory(p.join(outputDir.path, 'api')).create(recursive: true);
      await File(
        p.join(outputDir.path, 'api', 'index.mjs'),
      ).writeAsString('// old');
      await Directory(
        p.join(outputDir.path, 'tools', 'bun', 'bin'),
      ).create(recursive: true);
      await File(
        p.join(outputDir.path, 'tools', 'bun', 'bin', 'bun'),
      ).writeAsString('cached bun');

      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/cloudflare.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner: _compileStubRunner,
      );

      expect(code, 0);
      expect(File(p.join(outputDir.path, 'random.txt')).existsSync(), isFalse);
      expect(
        File(p.join(outputDir.path, 'api', 'index.mjs')).existsSync(),
        isFalse,
      );
      expect(
        File(p.join(outputDir.path, 'tools', 'bun', 'bin', 'bun')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(outputDir.path, 'src', 'app.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(outputDir.path, 'cloudflare', 'index.js')).existsSync(),
        isTrue,
      );
      expect(Directory(p.join(outputDir.path, 'public')).existsSync(), isFalse);
    });

    test('warns when cloudflare target has no wrangler config', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'cloudflare.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'cloudflare'}));
}
''');

      final out = StringBuffer();
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/cloudflare.dart'], string: ['config']),
        out,
        StringBuffer(),
        processRunner: _compileStubRunner,
      );

      expect(code, 0);
      expect(out.toString(), contains('Warning: no Wrangler config found.'));
    });

    test('fails when explicit wrangler config is missing', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'cloudflare.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({
    'target': 'cloudflare',
    'wranglerConfig': 'configs/missing.toml',
  }));
}
''');

      final err = StringBuffer();
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/cloudflare.dart'], string: ['config']),
        StringBuffer(),
        err,
        processRunner: _compileStubRunner,
      );

      expect(code, 1);
      expect(
        err.toString(),
        contains(
          'Configured wranglerConfig `configs/missing.toml` was not found.',
        ),
      );
    });

    test('writes vercel workspace files into .spry', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'vercel.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'vercel'}));
}
''');

      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/vercel.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner: _compileStubRunner,
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, '.spry', 'vercel', 'api', 'index.mjs'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'vercel', 'vercel.json')).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(root.path, '.spry', 'vercel', 'public')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'vercel', 'package.json')).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, '.spry', 'vercel', 'runtime', 'main.js'),
        ).existsSync(),
        isTrue,
      );
      expect(File(p.join(root.path, 'api', 'index.mjs')).existsSync(), isFalse);
      expect(File(p.join(root.path, 'vercel.json')).existsSync(), isFalse);
      expect(File(p.join(root.path, 'package.json')).existsSync(), isFalse);
    });

    test('writes netlify workspace files into .spry', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'netlify.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'netlify'}));
}
''');

      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/netlify.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner: _compileStubRunner,
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, '.spry', 'netlify', 'functions', 'index.mjs'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, '.spry', 'netlify', 'netlify.toml'),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(root.path, '.spry', 'netlify', 'public')).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, '.spry', 'netlify', 'runtime', 'main.js'),
        ).existsSync(),
        isTrue,
      );
      expect(File(p.join(root.path, 'netlify.toml')).existsSync(), isFalse);
    });

    test('compiles main.js for js targets', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'bun.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'bun'}));
}
''');

      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/bun.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _compileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'js',
                '.spry/src/main.dart',
                '-o',
                '.spry/bun/index.js',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'bun', 'index.js')).existsSync(),
        isTrue,
      );
    });

    test('compiles deno runtime into main.js', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'deno.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'deno'}));
}
''');

      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/deno.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _compileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'js',
                '.spry/src/main.dart',
                '-o',
                '.spry/deno/index.js',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'deno', 'index.js')).existsSync(),
        isTrue,
      );
    });

    test('compiles node runtime into hidden workspace', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'node.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'node'}));
}
''');
      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/node.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _compileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'js',
                '.spry/src/main.dart',
                '-o',
                '.spry/node/runtime/main.js',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'node', 'index.cjs')).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, '.spry', 'node', 'runtime', 'main.js'),
        ).existsSync(),
        isTrue,
      );
    });

    test('copies publicDir into vercel static workspace', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'vercel.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'vercel', 'publicDir': 'assets'}));
}
''');
      await Directory(p.join(root.path, 'assets')).create(recursive: true);
      await File(
        p.join(root.path, 'assets', 'hello.txt'),
      ).writeAsString('hello');

      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/vercel.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner: _compileStubRunner,
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, '.spry', 'vercel', 'public', 'hello.txt'),
        ).readAsStringSync(),
        'hello',
      );
    });

    test('copies publicDir into netlify static workspace', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'netlify.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'netlify', 'publicDir': 'assets'}));
}
''');
      await Directory(p.join(root.path, 'assets')).create(recursive: true);
      await File(
        p.join(root.path, 'assets', 'hello.txt'),
      ).writeAsString('hello');

      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/netlify.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner: _compileStubRunner,
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, '.spry', 'netlify', 'public', 'hello.txt'),
        ).readAsStringSync(),
        'hello',
      );
    });

    test('compiles vercel runtime into hidden workspace', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'vercel.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'vercel'}));
}
''');
      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/vercel.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _compileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'js',
                '.spry/src/main.dart',
                '-o',
                '.spry/vercel/runtime/main.js',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
    });

    test('compiles netlify runtime into hidden workspace', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'netlify.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'netlify'}));
}
''');
      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/netlify.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _compileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'js',
                '.spry/src/main.dart',
                '-o',
                '.spry/netlify/runtime/main.js',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
    });

    test('compiles exe target to dart/server', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'dart_exe.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'exe'}));
}
''');

      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/dart_exe.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _dartCompileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'exe',
                '.spry/src/main.dart',
                '-o',
                '.spry/dart/server',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'dart', 'server')).existsSync(),
        isTrue,
      );
    });

    test('compiles aot target to dart/server.aot', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'dart_aot.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'aot'}));
}
''');

      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/dart_aot.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _dartCompileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'aot-snapshot',
                '.spry/src/main.dart',
                '-o',
                '.spry/dart/server.aot',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
    });

    test('compiles jit target to dart/server.jit', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'dart_jit.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'jit'}));
}
''');

      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/dart_jit.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _dartCompileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'jit-snapshot',
                p.join('.spry', 'src', 'main.dart'),
                '-o',
                p.join('.spry', 'dart', 'server.jit'),
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
    });

    test('compiles kernel target to dart/server.dill', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'dart_kernel.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'kernel'}));
}
''');

      final runs = <(String executable, List<String> arguments, String? cwd)>[];
      final code = await runBuild(
        root.path,
        Args.parse(
          ['--config', 'configs/dart_kernel.dart'],
          string: ['config'],
        ),
        StringBuffer(),
        StringBuffer(),
        processRunner:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              runs.add((executable, arguments, workingDirectory));
              return _dartCompileStubRunner(
                executable,
                arguments,
                workingDirectory: workingDirectory,
                environment: environment,
                runInShell: runInShell,
                stdoutEncoding: stdoutEncoding,
                stderrEncoding: stderrEncoding,
              );
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.$1 == Platform.resolvedExecutable &&
              _sameArgs(it.$2, [
                'compile',
                'kernel',
                p.join('.spry', 'src', 'main.dart'),
                '-o',
                p.join('.spry', 'dart', 'server.dill'),
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
    });

    test('copies publicDir into dart compiled workspace', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'dart_exe.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'exe', 'publicDir': 'assets'}));
}
''');
      await Directory(p.join(root.path, 'assets')).create(recursive: true);
      await File(
        p.join(root.path, 'assets', 'hello.txt'),
      ).writeAsString('hello');

      final code = await runBuild(
        root.path,
        Args.parse(['--config', 'configs/dart_exe.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        processRunner: _dartCompileStubRunner,
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, '.spry', 'dart', 'public', 'hello.txt'),
        ).readAsStringSync(),
        'hello',
      );
    });
  });
}

Future<Directory> _copyFixture(String name) async {
  final source = Directory(
    p.normalize(p.absolute('test', 'fixtures', 'generator', name)),
  );
  final target = await _createRepoTempDir('spry_cli_test_');
  await _copyDirectory(source, target);
  return target;
}

final class _RouteSkeletonClientBuild {
  const _RouteSkeletonClientBuild({
    required this.root,
    required this.clientSource,
    required this.routesLibrary,
    required this.paramsLibrary,
    required this.rootRoutesSource,
    required this.healthRoutesSource,
    required this.usersRoutesSource,
    required this.usersByIdRoutesSource,
    required this.usersByIdParamsSource,
    required this.usersByIdProfileRoutesSource,
    required this.usersByIdProfileParamsFile,
    required this.patternsOptionalRoutesSource,
    required this.patternsOptionalParamsSource,
    required this.patternsRegexRoutesSource,
    required this.patternsRegexParamsSource,
    required this.patternsRepeatedOneRoutesSource,
    required this.patternsRepeatedOneParamsSource,
    required this.patternsRepeatedZeroRoutesSource,
    required this.patternsRepeatedZeroParamsSource,
    required this.patternsRemainderNamedRoutesSource,
    required this.patternsRemainderNamedParamsSource,
    required this.patternsRemainderUnnamedRoutesSource,
    required this.patternsRemainderUnnamedParamsSource,
    required this.patternsSingleWildcardRoutesSource,
    required this.patternsSingleWildcardParamsSource,
  });

  final Directory root;
  final String clientSource;
  final String routesLibrary;
  final String paramsLibrary;
  final String rootRoutesSource;
  final String healthRoutesSource;
  final String usersRoutesSource;
  final String usersByIdRoutesSource;
  final String usersByIdParamsSource;
  final String usersByIdProfileRoutesSource;
  final File usersByIdProfileParamsFile;
  final String patternsOptionalRoutesSource;
  final String patternsOptionalParamsSource;
  final String patternsRegexRoutesSource;
  final String patternsRegexParamsSource;
  final String patternsRepeatedOneRoutesSource;
  final String patternsRepeatedOneParamsSource;
  final String patternsRepeatedZeroRoutesSource;
  final String patternsRepeatedZeroParamsSource;
  final String patternsRemainderNamedRoutesSource;
  final String patternsRemainderNamedParamsSource;
  final String patternsRemainderUnnamedRoutesSource;
  final String patternsRemainderUnnamedParamsSource;
  final String patternsSingleWildcardRoutesSource;
  final String patternsSingleWildcardParamsSource;
}

Future<_RouteSkeletonClientBuild> _buildRouteSkeletonClient() async {
  final root = await _copyFixture('no_hooks');

  await File(p.join(root.path, 'routes', 'index.dart')).delete();
  for (final dir in [
    p.join(root.path, 'routes', 'users'),
    p.join(root.path, 'routes', 'users', '[id]', 'profile'),
    p.join(root.path, 'routes', 'patterns', 'optional'),
    p.join(root.path, 'routes', 'patterns', 'regex'),
    p.join(root.path, 'routes', 'patterns', 'repeated-one'),
    p.join(root.path, 'routes', 'patterns', 'repeated-zero'),
    p.join(root.path, 'routes', 'patterns', 'remainder-named'),
    p.join(root.path, 'routes', 'patterns', 'remainder-unnamed'),
    p.join(root.path, 'routes', 'patterns', 'single-wildcard'),
  ]) {
    await Directory(dir).create(recursive: true);
  }

  await File(p.join(root.path, 'spry.config.dart')).writeAsString('''
import 'package:spry/config.dart';

void main() {
  defineSpryConfig(client: .new());
}
''');

  for (final (path, source) in [
    (
      p.join(root.path, 'routes', 'index.get.dart'),
      '''
import 'package:spry/spry.dart';

Response handler(Event event) => Response('index');
''',
    ),
    (
      p.join(root.path, 'routes', 'health.get.dart'),
      '''
import 'package:spry/spry.dart';

Response handler(Event event) => Response('ok');
''',
    ),
    (
      p.join(root.path, 'routes', 'users', 'index.post.dart'),
      '''
import 'package:spry/spry.dart';

Response handler(Event event) => Response('created');
''',
    ),
    (
      p.join(root.path, 'routes', 'users', '[id].get.dart'),
      '''
import 'package:spry/spry.dart';

Response handler(Event event) => Response('user');
''',
    ),
    (
      p.join(root.path, 'routes', 'patterns', 'regex', '[id([0-9]+)].get.dart'),
      '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('regex');
''',
    ),
    (
      p.join(root.path, 'routes', 'patterns', 'optional', '[[id]].get.dart'),
      '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('optional');
''',
    ),
    (
      p.join(
        root.path,
        'routes',
        'patterns',
        'repeated-one',
        '[...path+].get.dart',
      ),
      '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('repeated-one');
''',
    ),
    (
      p.join(
        root.path,
        'routes',
        'patterns',
        'repeated-zero',
        '[[...path]].get.dart',
      ),
      '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('repeated-zero');
''',
    ),
    (
      p.join(
        root.path,
        'routes',
        'patterns',
        'remainder-named',
        '[...slug].get.dart',
      ),
      '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('remainder-named');
''',
    ),
    (
      p.join(
        root.path,
        'routes',
        'patterns',
        'remainder-unnamed',
        '[...].get.dart',
      ),
      '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('remainder-unnamed');
''',
    ),
    (
      p.join(
        root.path,
        'routes',
        'patterns',
        'single-wildcard',
        '[_].get.dart',
      ),
      '''
import 'package:spry/spry.dart';

Response handler(Event _) => Response('single-wildcard');
''',
    ),
    (
      p.join(root.path, 'routes', 'users', '[id]', 'profile', 'index.get.dart'),
      '''
import 'package:spry/spry.dart';

Response handler(Event event) => Response('profile');
''',
    ),
  ]) {
    await File(path).writeAsString(source);
  }

  final code = await runBuild(
    root.path,
    Args.parse(['client']),
    StringBuffer(),
    StringBuffer(),
  );
  expect(code, 0);

  String readClientFile(String path) => File(
    p.join(root.path, '.spry', 'client', 'lib', path),
  ).readAsStringSync();

  return _RouteSkeletonClientBuild(
    root: root,
    clientSource: readClientFile('client.dart'),
    routesLibrary: readClientFile('routes.dart'),
    paramsLibrary: readClientFile('params.dart'),
    rootRoutesSource: readClientFile(p.join('routes', 'index.dart')),
    healthRoutesSource: readClientFile(p.join('routes', 'health.dart')),
    usersRoutesSource: readClientFile(p.join('routes', 'users', 'index.dart')),
    usersByIdRoutesSource: readClientFile(
      p.join('routes', 'users', '[id].dart'),
    ),
    usersByIdParamsSource: readClientFile(
      p.join('params', 'users', '[id].dart'),
    ),
    usersByIdProfileRoutesSource: readClientFile(
      p.join('routes', 'users', '[id]', 'profile', 'index.dart'),
    ),
    usersByIdProfileParamsFile: File(
      p.join(
        root.path,
        '.spry',
        'client',
        'lib',
        'params',
        'users',
        '[id]',
        'profile',
        'index.dart',
      ),
    ),
    patternsOptionalRoutesSource: readClientFile(
      p.join('routes', 'patterns', 'optional', '[[id]].dart'),
    ),
    patternsOptionalParamsSource: readClientFile(
      p.join('params', 'patterns', 'optional', '[[id]].dart'),
    ),
    patternsRegexRoutesSource: readClientFile(
      p.join('routes', 'patterns', 'regex', '[id([0-9]+)].dart'),
    ),
    patternsRegexParamsSource: readClientFile(
      p.join('params', 'patterns', 'regex', '[id([0-9]+)].dart'),
    ),
    patternsRepeatedOneRoutesSource: readClientFile(
      p.join('routes', 'patterns', 'repeated-one', '[...path+].dart'),
    ),
    patternsRepeatedOneParamsSource: readClientFile(
      p.join('params', 'patterns', 'repeated-one', '[...path+].dart'),
    ),
    patternsRepeatedZeroRoutesSource: readClientFile(
      p.join('routes', 'patterns', 'repeated-zero', '[[...path]].dart'),
    ),
    patternsRepeatedZeroParamsSource: readClientFile(
      p.join('params', 'patterns', 'repeated-zero', '[[...path]].dart'),
    ),
    patternsRemainderNamedRoutesSource: readClientFile(
      p.join('routes', 'patterns', 'remainder-named', '[...slug].dart'),
    ),
    patternsRemainderNamedParamsSource: readClientFile(
      p.join('params', 'patterns', 'remainder-named', '[...slug].dart'),
    ),
    patternsRemainderUnnamedRoutesSource: readClientFile(
      p.join('routes', 'patterns', 'remainder-unnamed', '[...].dart'),
    ),
    patternsRemainderUnnamedParamsSource: readClientFile(
      p.join('params', 'patterns', 'remainder-unnamed', '[...].dart'),
    ),
    patternsSingleWildcardRoutesSource: readClientFile(
      p.join('routes', 'patterns', 'single-wildcard', '[_].dart'),
    ),
    patternsSingleWildcardParamsSource: readClientFile(
      p.join('params', 'patterns', 'single-wildcard', '[_].dart'),
    ),
  );
}

Future<Directory> _createRepoTempDir(String prefix) async {
  final base = Directory(p.normalize(p.absolute('.dart_tool', 'test_tmp')));
  await base.create(recursive: true);
  return base.createTemp(prefix);
}

Future<void> _copyDirectory(Directory source, Directory target) async {
  await for (final entity in source.list(recursive: false)) {
    final name = p.basename(entity.path);
    if (entity is Directory) {
      final child = Directory(p.join(target.path, name));
      await child.create(recursive: true);
      await _copyDirectory(entity, child);
      continue;
    }

    if (entity is File) {
      await entity.copy(p.join(target.path, name));
    }
  }
}

Future<ProcessResult> _compileStubRunner(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  Map<String, String>? environment,
  bool runInShell = false,
  Encoding? stdoutEncoding,
  Encoding? stderrEncoding,
}) async {
  if (arguments.length >= 5 &&
      arguments[0] == 'compile' &&
      arguments[1] == 'js') {
    final output = File(p.join(workingDirectory!, arguments[4]));
    await output.parent.create(recursive: true);
    await output.writeAsString('// compiled');
  }
  return ProcessResult(0, 0, '', '');
}

Future<ProcessResult> _dartCompileStubRunner(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  Map<String, String>? environment,
  bool runInShell = false,
  Encoding? stdoutEncoding,
  Encoding? stderrEncoding,
}) async {
  if (arguments.length >= 5 && arguments[0] == 'compile') {
    final output = File(p.join(workingDirectory!, arguments[4]));
    await output.parent.create(recursive: true);
    await output.writeAsString('// compiled');
  }
  return ProcessResult(0, 0, '', '');
}

bool _sameArgs(List<String> actual, List<String> expected) {
  return actual.length == expected.length &&
      actual.asMap().entries.every(
        (entry) => entry.value == expected[entry.key],
      );
}
