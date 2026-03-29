import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:test/test.dart';

import '../bin/src/build_pipeline.dart';

void main() {
  group('build progress', () {
    test('scanProjectTree reports scanner progress from scan events', () async {
      final root = await _copyFixture('complete');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final labels = <String>[];
      final tree = await scanProjectTree(
        BuildConfig(rootDir: root.path),
        progress: (label) async => labels.add(label),
      );

      expect(tree.routes, hasLength(3));
      expect(labels, isNotEmpty);
      expect(labels.first, 'scanning project tree...');
      expect(labels.last, contains('routes 3'));
      expect(labels.last, contains('middleware 4'));
      expect(labels.last, contains('errors 2'));
      expect(labels.last, contains('fallback 1'));
      expect(labels.last, contains('hooks 1'));
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
