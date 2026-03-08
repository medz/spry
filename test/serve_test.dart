import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../bin/src/serve.dart';

void main() {
  group('runServe', () {
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
      expect(starts.single.arguments, ['run', '.spry/main.dart']);
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
                '.spry/main.dart',
                '-o',
                '.spry/main.js',
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
      expect(starts.single.arguments, ['.spry/main.js']);
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
        '_worker.mjs',
        '--ip',
        '127.0.0.1',
        '--port',
        '8787',
      ]);
      expect(starts.single.workingDirectory, p.join(root.path, '.spry'));
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
              it.executable.endsWith(_bunFileName) &&
              _sameArgs(it.arguments, ['install']),
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
      expect(starts.single.workingDirectory, p.join(root.path, '.spry'));
    });

    test('restarts dart target when files change', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final events = StreamController<Object>();
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
      events.add(Object());
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
      final events = StreamController<Object>();
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
      events.add(Object());
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
  final target = await Directory.systemTemp.createTemp('spry_serve_test_');
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

Future<void> _waitUntil(bool Function() test) async {
  for (var i = 0; i < 50; i++) {
    if (test()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('Condition was not reached in time.');
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
