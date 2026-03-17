import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../bin/src/build.dart';

void main() {
  group('runBuild', () {
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
      expect(out.toString(), contains('Generated 3 file(s)'));
      expect(err.toString(), isEmpty);
      expect(File(p.join(root.path, '.spry', 'app.dart')).existsSync(), isTrue);
      expect(
        File(p.join(root.path, '.spry', 'hooks.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'main.dart')).existsSync(),
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
          p.join(root.path, 'generated', 'runtime', 'app.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, 'generated', 'runtime', 'hooks.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, 'generated', 'runtime', 'main.dart'),
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
        File(p.join(root.path, 'dist', 'runtime', 'app.dart')).existsSync(),
        isTrue,
      );
    });

    test('resolves project root from root override', () async {
      final workspace = await Directory.systemTemp.createTemp(
        'spry_cli_root_test_',
      );
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
      expect(File(p.join(root.path, '.spry', 'app.dart')).existsSync(), isTrue);
      expect(
        File(p.join(workspace.path, '.spry', 'app.dart')).existsSync(),
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
      expect(File(p.join(outputDir.path, 'app.dart')).existsSync(), isTrue);
      expect(
        File(p.join(outputDir.path, 'cloudflare.mjs')).existsSync(),
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
                '.spry/main.dart',
                '-o',
                '.spry/main.js',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
      expect(File(p.join(root.path, '.spry', 'main.js')).existsSync(), isTrue);
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
                '.spry/main.dart',
                '-o',
                '.spry/runtime/main.js',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
      expect(File(p.join(root.path, '.spry', 'main.cjs')).existsSync(), isTrue);
      expect(
        File(p.join(root.path, '.spry', 'runtime', 'main.js')).existsSync(),
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
                '.spry/main.dart',
                '-o',
                '.spry/vercel/runtime/main.js',
              ]) &&
              it.$3 == root.path,
        ),
        isTrue,
      );
    });
  });
}

Future<Directory> _copyFixture(String name) async {
  final source = Directory(
    p.normalize(p.absolute('test', 'fixtures', 'generator', name)),
  );
  final target = await Directory.systemTemp.createTemp('spry_cli_test_');
  await _copyDirectory(source, target);
  return target;
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

bool _sameArgs(List<String> actual, List<String> expected) {
  return actual.length == expected.length &&
      actual.asMap().entries.every(
        (entry) => entry.value == expected[entry.key],
      );
}
