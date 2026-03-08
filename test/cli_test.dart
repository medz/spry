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
      expect(
        File(p.join(root.path, '.spry', 'app.dart')).existsSync(),
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
      );

      expect(code, 0);
      expect(File(p.join(outputDir.path, 'random.txt')).existsSync(), isFalse);
      expect(
        File(p.join(outputDir.path, 'api', 'index.mjs')).existsSync(),
        isFalse,
      );
      expect(
        File(p.join(outputDir.path, 'tools', 'bun', 'bin', 'bun'))
            .existsSync(),
        isTrue,
      );
      expect(File(p.join(outputDir.path, 'app.dart')).existsSync(), isTrue);
      expect(
        File(p.join(outputDir.path, 'cloudflare.mjs')).existsSync(),
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
