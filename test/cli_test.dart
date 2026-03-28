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
        expect(out.toString(), contains('✓  built client'));
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

    test('generates route namespace skeleton for discovered routes', () async {
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
        p.join(root.path, 'routes', 'users', '[id]', 'profile'),
      ).create(recursive: true);

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
          p.join(
            root.path,
            'routes',
            'users',
            '[id]',
            'profile',
            'index.get.dart',
          ),
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

      final clientSource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'client.dart'),
      ).readAsStringSync();
      final routesLibrary = File(
        p.join(root.path, '.spry', 'client', 'lib', 'routes.dart'),
      ).readAsStringSync();
      final rootRoutesSource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'routes', 'index.dart'),
      ).readAsStringSync();
      final healthRoutesSource = File(
        p.join(root.path, '.spry', 'client', 'lib', 'routes', 'health.dart'),
      ).readAsStringSync();
      final usersRoutesSource = File(
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
      final usersByIdRoutesSource = File(
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
      final usersByIdProfileRoutesSource = File(
        p.join(
          root.path,
          '.spry',
          'client',
          'lib',
          'routes',
          'users',
          '[id]',
          'profile',
          'index.dart',
        ),
      ).readAsStringSync();

      expect(code, 0);
      expect(clientSource, contains("import 'routes.dart';"));
      expect(
        clientSource,
        contains('class SpryClient extends BaseSpryClient {'),
      );
      expect(
        clientSource,
        isNot(contains('final class SpryClient extends BaseSpryClient {')),
      );
      expect(clientSource, contains('late final root = RootRoutes(this);'));
      expect(clientSource, contains('late final health = HealthRoutes(this);'));
      expect(clientSource, contains('late final users = UsersRoutes(this);'));
      expect(clientSource, isNot(contains('final class UsersRoutes {')));
      expect(routesLibrary, contains("export 'routes/index.dart';"));
      expect(routesLibrary, contains("export 'routes/health.dart';"));
      expect(routesLibrary, contains("export 'routes/users/index.dart';"));
      expect(routesLibrary, contains("export 'routes/users/[id].dart';"));
      expect(
        routesLibrary,
        contains("export 'routes/users/[id]/profile/index.dart';"),
      );
      expect(rootRoutesSource, isNot(contains('final class RootRoutes {')));
      expect(
        rootRoutesSource,
        contains('class RootRoutes extends ClientRoutes {'),
      );
      expect(rootRoutesSource, contains('RootRoutes(super.client);'));
      expect(healthRoutesSource, isNot(contains('final class HealthRoutes {')));
      expect(
        healthRoutesSource,
        contains('class HealthRoutes extends ClientRoutes {'),
      );
      expect(healthRoutesSource, contains('HealthRoutes(super.client);'));
      expect(usersRoutesSource, isNot(contains('final class UsersRoutes {')));
      expect(
        usersRoutesSource,
        contains('class UsersRoutes extends ClientRoutes {'),
      );
      expect(usersRoutesSource, contains('UsersRoutes(super.client);'));
      expect(usersRoutesSource, contains("import '[id].dart';"));
      expect(
        usersRoutesSource,
        contains('late final byId = UsersByIdRoutes(client);'),
      );
      expect(
        usersByIdRoutesSource,
        contains("import '[id]/profile/index.dart';"),
      );
      expect(
        usersByIdRoutesSource,
        contains('late final profile = UsersByIdProfileRoutes(client);'),
      );
      expect(rootRoutesSource, isNot(contains('final BaseSpryClient client;')));
      expect(rootRoutesSource, isNot(contains('final SpryClient client;')));
      expect(
        rootRoutesSource,
        contains('Future<Object?> call() => throw UnimplementedError();'),
      );
      expect(
        usersByIdProfileRoutesSource,
        isNot(contains('final class UsersByIdProfileRoutes {')),
      );
      expect(
        usersByIdProfileRoutesSource,
        contains('class UsersByIdProfileRoutes extends ClientRoutes {'),
      );
      expect(
        usersByIdProfileRoutesSource,
        contains('UsersByIdProfileRoutes(super.client);'),
      );
      expect(
        usersByIdRoutesSource,
        contains(
          'Future<Object?> call({required String id}) => throw UnimplementedError();',
        ),
      );
      expect(
        usersByIdProfileRoutesSource,
        contains(
          'Future<Object?> call({required String id}) => throw UnimplementedError();',
        ),
      );
    });

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
      expect(out.toString(), contains('✓  built'));
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
