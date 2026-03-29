import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:test/test.dart';

import '../bin/src/progress.dart';

void main() {
  group('build progress', () {
    test('scan entries can be described directly from the stream', () async {
      final root = await _copyFixture('complete');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final labels = <String>[];
      await for (final entry in scanEntries(BuildConfig(rootDir: root.path))) {
        labels.add(describeScanEntry(entry, root.path));
      }

      expect(labels, isNotEmpty);
      expect(labels.first, startsWith('Scanning'));
      expect(labels, contains('Scanning route handlers: routes/index.dart'));
      expect(
        labels,
        contains('Scanning global middleware: middleware/02_auth.get.dart'),
      );
      expect(labels, contains('Scanning lifecycle hooks: hooks.dart'));
    });
  });
}

Future<Directory> _copyFixture(String name) async {
  final source = Directory(
    p.normalize(p.absolute('test', 'fixtures', 'generator', name)),
  );
  final target = await _createRepoTempDir('spry_build_progress_test_');
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
