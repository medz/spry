import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../bin/src/cli.dart';

void main() {
  group('runCli', () {
    test('prints usage for --help', () async {
      final out = StringBuffer();
      final err = StringBuffer();

      final code = await runCli(['--help'], stdoutSink: out, stderrSink: err);

      expect(code, 0);
      expect(out.toString(), contains('spry build'));
      expect(err.toString(), isEmpty);
    });

    test('build writes generated files into .spry', () async {
      final root = await _copyFixture('complete');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final out = StringBuffer();
      final err = StringBuffer();
      final code = await runCli(
        ['build'],
        currentDirectory: root.path,
        stdoutSink: out,
        stderrSink: err,
      );

      expect(code, 0);
      expect(out.toString(), contains('Generated 3 file(s)'));
      expect(err.toString(), isEmpty);
      expect(
        File(p.join(root.path, '.spry', 'app.g.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'hooks.g.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'main.dart')).existsSync(),
        isTrue,
      );
    });

    test('build respects output override', () async {
      final root = await _copyFixture('no_hooks');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final code = await runCli(
        ['build', '--output', 'generated/runtime'],
        currentDirectory: root.path,
        stdoutSink: StringBuffer(),
        stderrSink: StringBuffer(),
      );

      expect(code, 0);
      expect(
        File(
          p.join(root.path, 'generated', 'runtime', 'app.g.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, 'generated', 'runtime', 'hooks.g.dart'),
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
