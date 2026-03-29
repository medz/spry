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
      await for (final entry in scan(BuildConfig(rootDir: root.path))) {
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

    test('generated entries use root-relative display paths consistently', () {
      final label = describeGeneratedEntry(
        const GeneratedEntry(
          type: GeneratedEntryType.clientSource,
          path: '../client/lib/client.dart',
          content: '// generated',
          rootRelative: true,
        ),
        rootDir: '/tmp/project',
      );

      expect(label, 'Building client source: ../client/lib/client.dart');
    });

    test('scan observation surfaces failures through the entries stream', () async {
      final observed = observeScanEntries(
        Stream<ScanEntry>.error(StateError('boom')),
      );

      await expectLater(
        observed.entries.drain<void>(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'boom',
          ),
        ),
      );
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
  final base = Directory(
    p.normalize(p.absolute(p.join('.dart_tool', 'test_tmp'))),
  );
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
