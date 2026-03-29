import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';
import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import '../bin/src/write.dart';

void main() {
  group('stream pipeline', () {
    test('scan emits typed scan events', () async {
      final config = BuildConfig(rootDir: _fixture('complete'));

      final entries = await scan(config).toList();

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
      expect(
        entries
            .where((it) => it.type == ScanEntryType.route)
            .map((it) => (it.route!.path, p.basename(it.route!.filePath))),
        contains(('/about', 'about.get.dart')),
      );
    });

    test(
      'generate emits runtime source entries before target artifacts',
      () async {
        final config = BuildConfig(
          rootDir: _fixture('no_hooks'),
          target: BuildTarget.node,
        );

        final entries = await generate(scan(config), config).toList();

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
      'generate emits openapi artifacts through the unified stream',
      () async {
        final config = BuildConfig(
          rootDir: _fixture('with_openapi'),
          openapi: OpenAPIConfig(
            document: OpenAPIDocumentConfig(
              info: OpenAPIInfo(title: 'Fixture API', version: '1.0.0'),
            ),
          ),
        );

        final entries = await generate(scan(config), config).toList();
        final openapiEntry = entries.singleWhere(
          (it) => it.type == GeneratedEntryType.openapiArtifact,
        );

        expect(openapiEntry.path, 'public/openapi.json');
        expect(openapiEntry.rootRelative, isTrue);
      },
    );

    test(
      'generate emits client source artifacts through the unified stream',
      () async {
        final config = BuildConfig(
          rootDir: _fixture('complete'),
          client: ClientConfig(),
        );

        final entries = await generate(scan(config), config).toList();

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
      'writeGeneratedFiles allows client source artifacts outside the project root',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'spry_stream_pipeline_client_write_',
        );
        final siblingClient = Directory(
          p.join(p.dirname(root.path), 'external_client'),
        );
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
          if (await siblingClient.exists()) {
            await siblingClient.delete(recursive: true);
          }
        });

        final config = BuildConfig(rootDir: root.path);

        await writeGeneratedFiles(
          Stream.fromIterable([
            const GeneratedEntry(
              type: GeneratedEntryType.clientSource,
              path: '../external_client/lib/client.dart',
              content: 'client',
              rootRelative: true,
            ),
          ]),
          config,
        );

        final file = File(p.join(siblingClient.path, 'lib', 'client.dart'));
        expect(await file.exists(), isTrue);
        expect(await file.readAsString(), 'client');
      },
    );
  });
}

String _fixture(String name) =>
    p.normalize(p.absolute('test', 'fixtures', 'generator', name));
