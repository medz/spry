import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:test/test.dart';

import '../bin/src/write.dart';

void main() {
  group('stream pipeline', () {
    test(
      'scanEntries emits typed scan events collectable into a route tree',
      () async {
        final config = BuildConfig(rootDir: _fixture('complete'));

        final entries = await scanEntries(config).toList();

        expect(entries.map((it) => it.type), contains(ScanEntryType.route));
        expect(
          entries.map((it) => it.type),
          containsAll([
            ScanEntryType.globalMiddleware,
            ScanEntryType.scopedMiddleware,
            ScanEntryType.scopedError,
            ScanEntryType.fallback,
            ScanEntryType.hooks,
          ]),
        );

        final tree = await collectRouteTree(Stream.fromIterable(entries));

        expect(
          tree.routes.map((it) => (it.path, p.basename(it.filePath))),
          contains(('/about', 'about.get.dart')),
        );
        expect(tree.fallback, isNotNull);
        expect(tree.hooks, isNotNull);
      },
    );

    test(
      'generateEntries emits typed generated entries from scan events',
      () async {
        final config = BuildConfig(rootDir: _fixture('no_hooks'));

        final entries = await generateEntries(
          scanEntries(config),
          config,
        ).toList();

        expect(
          entries.map((it) => it.type),
          contains(GeneratedEntryType.runtimeSource),
        );
        expect(
          entries.map((it) => it.path),
          containsAll(['src/app.dart', 'src/hooks.dart', 'src/main.dart']),
        );
      },
    );

    test('writeGeneratedEntries writes generated entry streams', () async {
      final root = await Directory.systemTemp.createTemp(
        'spry_stream_pipeline_write_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final config = BuildConfig(rootDir: root.path);

      await writeGeneratedEntries(
        Stream.fromIterable([
          const GeneratedEntry(
            type: GeneratedEntryType.runtimeSource,
            path: 'src/app.dart',
            content: '// app',
          ),
          const GeneratedEntry(
            type: GeneratedEntryType.runtimeSource,
            path: 'src/main.dart',
            content: '// main',
          ),
        ]),
        config,
      );

      expect(
        File(p.join(root.path, '.spry', 'src', 'app.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(root.path, '.spry', 'src', 'main.dart')).readAsStringSync(),
        '// main',
      );
    });
  });
}

String _fixture(String name) =>
    p.normalize(p.absolute('test', 'fixtures', 'generator', name));
