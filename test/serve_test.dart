import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../bin/src/serve.dart';

void main() {
  group('runServe', () {
    test('MCP startup failure closes the spawned runner', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() => root.delete(recursive: true));
      final occupied = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => occupied.close(force: true));
      await _writeMcpConfig(root, port: occupied.port);
      final process = _FakeProcess.pending();
      addTearDown(() => process.complete(0));
      final err = StringBuffer();
      final code = await runServe(
        root.path,
        Args.parse(const []),
        StringBuffer(),
        err,
        watchEvents: const Stream.empty(),
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async => process,
      );
      expect(code, 1, reason: err.toString());
      expect(process.killed, isTrue, reason: err.toString());
    });

    test('MCP closes when the runner exits', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() => root.delete(recursive: true));
      final port = await _freePort();
      await _writeMcpConfig(root, port: port);
      final process = _FakeProcess.pending();
      final out = StringBuffer();
      final err = StringBuffer();
      final events = StreamController<String>();
      addTearDown(events.close);
      addTearDown(() => process.complete(0));
      final serving = runServe(
        root.path,
        Args.parse(const []),
        out,
        err,
        watchEvents: events.stream,
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async => process,
      );
      await _waitUntil(() => out.toString().contains('MCP:')).catchError((
        Object error,
      ) {
        throw StateError('$error\n$out\n$err');
      });
      await _callMcp(port, 'spry.get_config');
      process.complete(0);
      expect(await serving, 0);
      await expectLater(
        _callMcp(port, 'spry.get_config'),
        throwsA(isA<SocketException>()),
      );
      expect(events.hasListener, isFalse);
    });

    test(
      'hotswap refreshes MCP routes and config without restarting runner',
      () async {
        final root = await _copyFixture('no_hooks');
        addTearDown(() => root.delete(recursive: true));
        final port = await _freePort();
        await _writeMcpConfig(root, port: port, target: 'cloudflare');
        await _writeFakeBun(p.join(root.path, '.spry', 'tools', 'bun', 'bin'));
        final events = StreamController<String>();
        addTearDown(events.close);
        final process = _FakeProcess.pending();
        addTearDown(() => process.complete(0));
        final out = StringBuffer();
        final err = StringBuffer();
        var starts = 0;
        final serving = runServe(
          root.path,
          Args.parse(const []),
          out,
          err,
          watchEvents: events.stream,
          processRunner:
              (
                executable,
                arguments, {
                workingDirectory,
                environment,
                runInShell = false,
                stdoutEncoding,
                stderrEncoding,
              }) async => ProcessResult(0, 0, '', ''),
          processStarter:
              (
                executable,
                arguments, {
                workingDirectory,
                environment,
                includeParentEnvironment = true,
                runInShell = false,
                mode = ProcessStartMode.normal,
              }) async {
                starts++;
                return process;
              },
        );
        await _waitUntil(() => out.toString().contains('MCP:')).catchError((
          Object error,
        ) {
          throw StateError('$error\n$out\n$err');
        });
        final before = await _callMcp(port, 'spry.get_project_info');
        await File(p.join(root.path, 'routes', 'added.get.dart')).writeAsString(
          "import 'package:spry/spry.dart';\nResponse handler(Event event) => Response('added');\n",
        );
        await _writeMcpConfig(
          root,
          port: port,
          target: 'cloudflare',
          caseSensitive: false,
        );
        events.add('routes/added.get.dart');
        await _waitUntil(
          () => out.toString().contains('rebuilt in'),
        ).catchError((Object error) {
          throw StateError('$error\n$out\n$err');
        });
        final after = await _callMcp(port, 'spry.get_project_info');
        expect(after['route_count'], (before['route_count'] as int) + 1);
        expect(
          (await _callMcp(port, 'spry.get_config'))['case_sensitive'],
          isFalse,
        );
        expect(starts, 1);
        expect(process.killed, isFalse);

        // Configuration changes must also rebind and disable the MCP endpoint.
        final nextPort = await _freePort();
        await _writeMcpConfig(root, port: nextPort, target: 'cloudflare');
        out.clear();
        events.add('spry.config.dart');
        await _waitUntil(() => out.toString().contains('rebuilt in'));
        expect(
          (await _callMcp(nextPort, 'spry.get_project_info'))['route_count'],
          2,
        );
        await expectLater(
          _callMcp(port, 'spry.get_config'),
          throwsA(isA<SocketException>()),
        );

        await _writeMcpConfig(
          root,
          port: nextPort,
          target: 'cloudflare',
          enable: false,
        );
        out.clear();
        events.add('spry.config.dart');
        await _waitUntil(() => out.toString().contains('rebuilt in'));
        await expectLater(
          _callMcp(nextPort, 'spry.get_config'),
          throwsA(isA<SocketException>()),
        );

        await _writeMcpConfig(root, port: nextPort, target: 'cloudflare');
        out.clear();
        events.add('spry.config.dart');
        await _waitUntil(() => out.toString().contains('rebuilt in'));
        expect(
          (await _callMcp(nextPort, 'spry.get_project_info'))['route_count'],
          2,
        );
        expect(starts, 1);
        expect(process.killed, isFalse);
        process.complete(0);
        expect(await serving, 0);
      },
    );

    test('starts dart target with generated main.dart', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final starts = <_StartedProcess>[];
      final code = await runServe(
        root.path,
        Args.parse(const []),
        StringBuffer(),
        StringBuffer(),
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return _FakeProcess(0);
            },
      );

      expect(code, 0);
      expect(starts, hasLength(1));
      expect(starts.single.executable, Platform.resolvedExecutable);
      expect(starts.single.arguments, [
        'run',
        p.join('.spry', 'src', 'main.dart'),
      ]);
      expect(starts.single.workingDirectory, root.path);
      expect(starts.single.mode, ProcessStartMode.inheritStdio);
    });

    test('compiles js and runs node target with bun', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'serve.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'node'}));
}
''');

      await _writeFakeBun(p.join(root.path, '.spry', 'tools', 'bun', 'bin'));
      final runs = <_RunProcess>[];
      final starts = <_StartedProcess>[];
      final code = await runServe(
        root.path,
        Args.parse(['--config', 'configs/serve.dart'], string: ['config']),
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
              runs.add(
                _RunProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                ),
              );
              return ProcessResult(0, 0, '', '');
            },
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return _FakeProcess(0);
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.executable == Platform.resolvedExecutable &&
              _sameArgs(it.arguments, [
                'compile',
                'js',
                p.join('.spry', 'src', 'main.dart'),
                '-o',
                p.join('.spry', 'node', 'runtime', 'main.js'),
              ]),
        ),
        isTrue,
      );
      expect(
        runs.any(
          (it) =>
              it.executable.endsWith(_bunFileName) &&
              _sameArgs(it.arguments, ['--version']),
        ),
        isTrue,
      );
      expect(starts, hasLength(1));
      expect(starts.single.executable.endsWith(_bunFileName), isTrue);
      expect(starts.single.arguments, [p.join('.spry', 'node', 'index.cjs')]);
      expect(starts.single.workingDirectory, root.path);
    });

    test('compiles js and runs deno target with allow-net', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'serve.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({'target': 'deno'}));
}
''');

      final runs = <_RunProcess>[];
      final starts = <_StartedProcess>[];
      final code = await runServe(
        root.path,
        Args.parse(['--config', 'configs/serve.dart'], string: ['config']),
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
              runs.add(
                _RunProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                ),
              );
              return ProcessResult(0, 0, '', '');
            },
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return _FakeProcess(0);
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.executable == Platform.resolvedExecutable &&
              _sameArgs(it.arguments, [
                'compile',
                'js',
                p.join('.spry', 'src', 'main.dart'),
                '-o',
                p.join('.spry', 'deno', 'index.js'),
              ]),
        ),
        isTrue,
      );
      expect(starts, hasLength(1));
      expect(starts.single.executable, 'deno');
      expect(starts.single.arguments, [
        'run',
        '--allow-net',
        p.join('.spry', 'deno', 'index.js'),
      ]);
      expect(starts.single.workingDirectory, root.path);
    });

    test('resolves project root from root override', () async {
      final workspace = await _createRepoTempDir('spry_serve_root_test_');
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

      final starts = <_StartedProcess>[];
      final code = await runServe(
        workspace.path,
        Args.parse(['--root', 'example'], string: ['root']),
        StringBuffer(),
        StringBuffer(),
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return _FakeProcess(0);
            },
      );

      expect(code, 0);
      expect(starts, hasLength(1));
      expect(starts.single.workingDirectory, root.path);
    });

    test('starts cloudflare target with wrangler dev', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'serve.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({
    'target': 'cloudflare',
    'host': '127.0.0.1',
    'port': 8787,
  }));
}
''');
      await File(p.join(root.path, 'wrangler.toml')).writeAsString('''
name = "spry-example"
main = ".spry/cloudflare/index.js"
''');

      await _writeFakeBun(p.join(root.path, '.spry', 'tools', 'bun', 'bin'));
      final starts = <_StartedProcess>[];
      final code = await runServe(
        root.path,
        Args.parse(['--config', 'configs/serve.dart'], string: ['config']),
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
              return ProcessResult(0, 0, '', '');
            },
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return _FakeProcess(0);
            },
      );

      expect(code, 0);
      expect(starts, hasLength(1));
      expect(starts.single.executable.endsWith(_bunFileName), isTrue);
      expect(starts.single.arguments, [
        'x',
        'wrangler',
        'dev',
        '--config',
        'wrangler.toml',
        '--ip',
        '127.0.0.1',
        '--port',
        '8787',
      ]);
      expect(starts.single.workingDirectory, root.path);
    });

    test('starts vercel target with local listen mode', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'serve.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({
    'target': 'vercel',
    'host': '127.0.0.1',
    'port': 3000,
  }));
}
''');

      await _writeFakeBun(p.join(root.path, '.spry', 'tools', 'bun', 'bin'));
      final runs = <_RunProcess>[];
      final starts = <_StartedProcess>[];
      final code = await runServe(
        root.path,
        Args.parse(['--config', 'configs/serve.dart'], string: ['config']),
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
              runs.add(
                _RunProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                ),
              );
              return ProcessResult(0, 0, '', '');
            },
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return _FakeProcess(0);
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.executable == Platform.resolvedExecutable &&
              _sameArgs(it.arguments, [
                'compile',
                'js',
                p.join('.spry', 'src', 'main.dart'),
                '-o',
                p.join('.spry', 'vercel', 'runtime', 'main.js'),
              ]),
        ),
        isTrue,
      );
      expect(
        runs.any(
          (it) =>
              it.executable.endsWith(_bunFileName) &&
              _sameArgs(it.arguments, ['install']) &&
              it.workingDirectory == p.join(root.path, '.spry', 'vercel'),
        ),
        isTrue,
      );
      expect(starts, hasLength(1));
      expect(starts.single.executable.endsWith(_bunFileName), isTrue);
      expect(starts.single.arguments, [
        'x',
        'vercel',
        'dev',
        '--local',
        '--yes',
        '--listen',
        '127.0.0.1:3000',
      ]);
      expect(
        starts.single.workingDirectory,
        p.join(root.path, '.spry', 'vercel'),
      );
    });

    test('starts netlify target from generated workspace', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'serve.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({
    'target': 'netlify',
    'host': '127.0.0.1',
    'port': 3000,
  }));
}
''');

      await _writeFakeBun(p.join(root.path, '.spry', 'tools', 'bun', 'bin'));
      final runs = <_RunProcess>[];
      final starts = <_StartedProcess>[];
      final code = await runServe(
        root.path,
        Args.parse(['--config', 'configs/serve.dart'], string: ['config']),
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
              runs.add(
                _RunProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                ),
              );
              return ProcessResult(0, 0, '', '');
            },
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return _FakeProcess(0);
            },
      );

      expect(code, 0);
      expect(
        runs.any(
          (it) =>
              it.executable == Platform.resolvedExecutable &&
              _sameArgs(it.arguments, [
                'compile',
                'js',
                p.join('.spry', 'src', 'main.dart'),
                '-o',
                p.join('.spry', 'netlify', 'runtime', 'main.js'),
              ]),
        ),
        isTrue,
      );
      expect(starts, hasLength(1));
      expect(starts.single.executable.endsWith(_bunFileName), isTrue);
      expect(starts.single.arguments, [
        'x',
        'netlify',
        'dev',
        '--port',
        '3000',
      ]);
      expect(
        starts.single.workingDirectory,
        p.join(root.path, '.spry', 'netlify'),
      );
    });

    test('restarts dart target when files change', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final events = StreamController<String>();
      final first = _FakeProcess.pending();
      final second = _FakeProcess(0);
      final starts = <_StartedProcess>[];
      final serve = runServe(
        root.path,
        Args.parse(const []),
        StringBuffer(),
        StringBuffer(),
        watchEvents: events.stream,
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return starts.length == 1 ? first : second;
            },
      );

      await _waitUntil(() => starts.length == 1);
      events.add('routes/index.dart');
      await serve;

      expect(starts, hasLength(2));
      expect(first.killed, isTrue);
    });

    test('hotswap keeps cloudflare runner alive', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configDir = Directory(p.join(root.path, 'configs'));
      await configDir.create(recursive: true);
      await File(p.join(configDir.path, 'serve.dart')).writeAsString('''
import 'dart:convert';

void main() {
  print(jsonEncode({
    'target': 'cloudflare',
    'reload': 'hotswap',
  }));
}
''');

      await _writeFakeBun(p.join(root.path, '.spry', 'tools', 'bun', 'bin'));
      final events = StreamController<String>();
      final process = _FakeProcess.pending();
      final runs = <_RunProcess>[];
      final starts = <_StartedProcess>[];
      final serve = runServe(
        root.path,
        Args.parse(['--config', 'configs/serve.dart'], string: ['config']),
        StringBuffer(),
        StringBuffer(),
        watchEvents: events.stream,
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
              runs.add(
                _RunProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                ),
              );
              return ProcessResult(0, 0, '', '');
            },
        processStarter:
            (
              executable,
              arguments, {
              workingDirectory,
              environment,
              includeParentEnvironment = true,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              starts.add(
                _StartedProcess(
                  executable: executable,
                  arguments: arguments,
                  workingDirectory: workingDirectory,
                  mode: mode,
                ),
              );
              return process;
            },
      );

      await _waitUntil(() => starts.length == 1 && runs.length >= 2);
      events.add('routes/index.dart');
      await _waitUntil(() => runs.length >= 4);
      process.complete(0);
      await serve;

      expect(starts, hasLength(1));
      expect(process.killed, isFalse);
    });
  });
}

Future<Directory> _copyFixture(String name) async {
  final source = Directory(
    p.normalize(p.absolute('test', 'fixtures', 'generator', name)),
  );
  final target = await _createRepoTempDir('spry_serve_test_');
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

Future<String> _writeFakeBun(
  String directory, {
  String version = '1.0.0',
}) async {
  final file = File(p.join(directory, _bunFileName));
  await file.parent.create(recursive: true);

  if (Platform.isWindows) {
    await file.writeAsString('@echo off\r\necho $version\r\n');
  } else {
    await file.writeAsString('#!/bin/sh\necho "$version"\n');
    await Process.run('chmod', ['+x', file.path]);
  }

  return file.path;
}

String get _bunFileName => Platform.isWindows ? 'bun.exe' : 'bun';

bool _sameArgs(List<String> actual, List<String> expected) {
  if (actual.length != expected.length) {
    return false;
  }

  for (var i = 0; i < actual.length; i++) {
    if (actual[i] != expected[i]) {
      return false;
    }
  }

  return true;
}

Future<void> _waitUntil(
  bool Function() test, {
  Duration timeout = const Duration(seconds: 15),
  Duration interval = const Duration(milliseconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (test()) {
      return;
    }
    await Future<void>.delayed(interval);
  }
  throw StateError('Condition was not reached within $timeout.');
}

final class _RunProcess {
  const _RunProcess({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
  });

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;
}

final class _StartedProcess {
  const _StartedProcess({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
    required this.mode,
  });

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;
  final ProcessStartMode mode;
}

final class _FakeProcess implements Process {
  _FakeProcess(int exitCode)
    : _exitCode = Future<int>.value(exitCode),
      _completer = null;

  _FakeProcess.pending() : _exitCode = null, _completer = Completer<int>();

  final Future<int>? _exitCode;
  final Completer<int>? _completer;
  final _stdout = StreamController<List<int>>.broadcast();
  final _stderr = StreamController<List<int>>.broadcast();
  final _stdin = _FakeIOSink();
  var killed = false;

  @override
  Future<int> get exitCode => _exitCode ?? _completer!.future;

  @override
  int get pid => 1;

  @override
  IOSink get stdin => _stdin;

  @override
  Stream<List<int>> get stdout => _stdout.stream;

  @override
  Stream<List<int>> get stderr => _stderr.stream;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    complete(0);
    return true;
  }

  void complete(int code) {
    if (_completer case final completer?) {
      if (!completer.isCompleted) {
        completer.complete(code);
      }
    }
  }
}

final class _FakeIOSink implements IOSink {
  @override
  Encoding encoding = utf8;

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) => Future.value();

  @override
  Future close() => Future.value();

  @override
  Future get done => Future.value();

  @override
  Future flush() => Future.value();

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}
}

Future<int> _freePort() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final port = server.port;
  await server.close(force: true);
  return port;
}

Future<void> _writeMcpConfig(
  Directory root, {
  required int port,
  String target = 'vm',
  bool caseSensitive = true,
  bool enable = true,
}) => File(p.join(root.path, 'spry.config.dart')).writeAsString(
  "import 'dart:convert';\nvoid main() { print(jsonEncode(${jsonEncode({
    'host': '127.0.0.1',
    'target': target,
    'reload': 'hotswap',
    'caseSensitive': caseSensitive,
    'mcp': {'enable': enable, 'port': port},
  })})); }\n",
);

Future<Map<String, dynamic>> _callMcp(int port, String tool) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('http://127.0.0.1:$port/'));
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'tools/call',
        'params': {'name': tool},
      }),
    );
    final response = await request.close();
    final body =
        jsonDecode(await response.transform(utf8.decoder).join()) as Map;
    return jsonDecode(body['result']['content'][0]['text'] as String)
        as Map<String, dynamic>;
  } finally {
    client.close(force: true);
  }
}
