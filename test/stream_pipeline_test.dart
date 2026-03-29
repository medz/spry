import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';
import 'package:spry/openapi.dart';
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

    test('scan remains equivalent to collecting scanEntries', () async {
      final config = BuildConfig(rootDir: _fixture('complete'));

      final tree = await scan(config);
      final collected = await collectRouteTree(scanEntries(config));

      expect(
        collected.routes.map((it) => (it.path, it.method, it.wildcardParam)),
        tree.routes.map((it) => (it.path, it.method, it.wildcardParam)),
      );
      expect(
        collected.globalMiddleware.map((it) => (it.path, it.method)),
        tree.globalMiddleware.map((it) => (it.path, it.method)),
      );
      expect(
        collected.scopedMiddleware.map((it) => (it.path, it.method)),
        tree.scopedMiddleware.map((it) => (it.path, it.method)),
      );
      expect(
        collected.scopedErrors.map((it) => (it.path, it.method)),
        tree.scopedErrors.map((it) => (it.path, it.method)),
      );
      expect(collected.fallback?.path, tree.fallback?.path);
      expect(collected.hooks?.filePath, tree.hooks?.filePath);
      expect(collected.hooks?.hasOnStart, tree.hooks?.hasOnStart);
      expect(collected.hooks?.hasOnStop, tree.hooks?.hasOnStop);
      expect(collected.hooks?.hasOnError, tree.hooks?.hasOnError);
    });

    test('scanEntries emits base scan events in scanning order', () async {
      final config = BuildConfig(rootDir: _fixture('complete'));

      final entries = await scanEntries(config).toList();

      expect(
        entries
            .where((it) => it.type == ScanEntryType.globalMiddleware)
            .map((it) => p.basename(it.middleware!.filePath)),
        ['01_logger.dart', '02_auth.get.dart'],
      );
      expect(
        entries
            .where((it) => it.type == ScanEntryType.route)
            .map(
              (it) => p.relative(
                it.route!.filePath,
                from: p.join(config.rootDir, 'routes'),
              ),
            ),
        ['about.get.dart', 'index.dart', p.join('users', '[id].dart')],
      );
      expect(entries.any((it) => it.type == ScanEntryType.fallback), isTrue);
      expect(entries.any((it) => it.type == ScanEntryType.hooks), isTrue);
    });

    test(
      'scanEntries emits route events with openapi metadata attached',
      () async {
        final config = BuildConfig(rootDir: _fixture('with_openapi'));

        final entries = await scanEntries(config).toList();
        final routeEntry = entries.singleWhere(
          (it) => it.type == ScanEntryType.route && it.route!.path == '/',
        );

        expect(routeEntry.route!.openapi, isNotNull);
        expect(routeEntry.route!.openapi!['summary'], 'Home');
        expect(
          routeEntry.route!.openapi!['responses'],
          isA<Map<String, Object?>>(),
        );
      },
    );

    test(
      'scanEntries emits hooks events with resolved hooks metadata',
      () async {
        final config = BuildConfig(rootDir: _fixture('complete'));

        final entries = await scanEntries(config).toList();
        final hooksEntry = entries.singleWhere(
          (it) => it.type == ScanEntryType.hooks,
        );

        expect(hooksEntry.hooks, isNotNull);
        expect(p.basename(hooksEntry.hooks!.filePath), 'hooks.dart');
        expect(hooksEntry.hooks!.hasOnStart, isTrue);
        expect(hooksEntry.hooks!.hasOnStop, isFalse);
        expect(hooksEntry.hooks!.hasOnError, isFalse);
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

    test(
      'generateEntries emits runtime source entries before target artifacts',
      () async {
        final config = BuildConfig(
          rootDir: _fixture('no_hooks'),
          target: BuildTarget.node,
        );

        final entries = await generateEntries(
          scanEntries(config),
          config,
        ).toList();

        expect(entries.take(3).map((it) => (it.type, it.path)), [
          (GeneratedEntryType.runtimeSource, 'src/app.dart'),
          (GeneratedEntryType.runtimeSource, 'src/hooks.dart'),
          (GeneratedEntryType.runtimeSource, 'src/main.dart'),
        ]);
        expect(
          entries.skip(3).map((it) => it.type),
          everyElement(GeneratedEntryType.targetArtifact),
        );
      },
    );

    test(
      'generateEntries emits openapi artifacts through the unified generation stream',
      () async {
        final config = BuildConfig(
          rootDir: _fixture('with_openapi'),
          openapi: OpenAPIConfig(
            document: OpenAPIDocumentConfig(
              info: OpenAPIInfo(title: 'Fixture API', version: '1.0.0'),
            ),
          ),
        );

        final entries = await generateEntries(
          scanEntries(config),
          config,
        ).toList();
        final openapiEntry = entries.singleWhere(
          (it) => it.type == GeneratedEntryType.openapiArtifact,
        );

        expect(openapiEntry.path, 'public/openapi.json');
        expect(openapiEntry.rootRelative, isTrue);
      },
    );

    test(
      'generateEntries emits client source artifacts through the unified generation stream',
      () async {
        final config = BuildConfig(
          rootDir: _fixture('complete'),
          client: ClientConfig(),
        );

        final entries = await generateEntries(
          scanEntries(config),
          config,
        ).toList();

        expect(
          entries.map((it) => it.type),
          contains(GeneratedEntryType.clientSource),
        );
        expect(
          entries.map((it) => it.path),
          containsAll([
            '.spry/client/lib/client.dart',
            '.spry/client/lib/routes.dart',
            '.spry/client/lib/params.dart',
          ]),
        );
      },
    );

    test(
      'generateEntries preserves legacy generate output semantics',
      () async {
        final config = BuildConfig(rootDir: _fixture('complete'));

        final legacyTree = await scan(config);
        final legacyFiles = await generate(legacyTree, config);
        final streamedEntries = await generateEntries(
          scanEntries(config),
          config,
        ).toList();

        expect(
          streamedEntries.map(
            (it) => (it.path, it.rootRelative, it.writeIfMissing, it.content),
          ),
          legacyFiles.map(
            (it) => (it.path, it.rootRelative, it.writeIfMissing, it.content),
          ),
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
