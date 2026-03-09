import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../bin/src/tools/bun.dart';

void main() {
  group('resolveBunExecutable', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('spry_bun_test_');
    });

    tearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    test('prefers system bun from PATH', () async {
      final systemBin = Directory(p.join(root.path, 'system-bin'));
      await systemBin.create(recursive: true);
      final systemBun = await _writeFakeBun(systemBin.path, version: '1.0.0');

      final localBun = await _writeFakeBun(
        p.join(root.path, '.spry', 'tools', 'bun', 'bin'),
        version: '0.9.0',
      );

      final resolved = await resolveBunExecutable(
        root.path,
        environment: {'PATH': systemBin.path},
      );

      expect(resolved, systemBun);
      expect(resolved, isNot(localBun));
    });

    test('falls back to project-local bun when system bun is absent', () async {
      final localBun = await _writeFakeBun(
        p.join(root.path, '.spry', 'tools', 'bun', 'bin'),
      );

      final resolved = await resolveBunExecutable(
        root.path,
        environment: {'PATH': p.join(root.path, 'missing-bin')},
      );

      expect(resolved, localBun);
    });

    test('uses installer when no bun is available', () async {
      final resolved = await resolveBunExecutable(
        root.path,
        environment: {'PATH': p.join(root.path, 'missing-bin')},
        installBun: (cwd) async {
          return _writeFakeBun(p.join(cwd, '.spry', 'tools', 'bun', 'bin'));
        },
      );

      expect(
        resolved,
        p.join(root.path, '.spry', 'tools', 'bun', 'bin', _bunFileName),
      );
      expect(File(resolved).existsSync(), isTrue);
    });

    test('installs bun into the project-local tools directory', () async {
      late String executable;
      late List<String> arguments;
      late String? seenWorkingDirectory;
      late Map<String, String>? seenEnvironment;

      final resolved = await installProjectBun(
        root.path,
        environment: {'PATH': '/usr/bin'},
        processRunner:
            (
              exe,
              args, {
              workingDirectory,
              environment,
              runInShell = false,
              stdoutEncoding,
              stderrEncoding,
            }) async {
              executable = exe;
              arguments = args;
              seenWorkingDirectory = workingDirectory;
              seenEnvironment = environment;
              await _writeFakeBun(
                p.join(root.path, '.spry', 'tools', 'bun', 'bin'),
              );
              return ProcessResult(1, 0, '', '');
            },
      );

      expect(resolved, projectBunExecutablePath(root.path));
      expect(seenWorkingDirectory, root.path);
      expect(seenEnvironment?['BUN_INSTALL'], projectBunInstallRoot(root.path));
      expect(seenEnvironment?['PATH'], '/usr/bin');
      if (Platform.isWindows) {
        expect(executable, 'powershell');
        expect(arguments, [
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          'irm bun.com/install.ps1 | iex',
        ]);
      } else {
        expect(executable, '/bin/sh');
        expect(arguments, ['-c', 'curl -fsSL https://bun.com/install | bash']);
      }
    });
  });
}

String get _bunFileName => Platform.isWindows ? 'bun.exe' : 'bun';

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
