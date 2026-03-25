import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';
import 'package:test/test.dart';

import '../bin/src/write.dart';

void main() {
  group('writeGeneratedFiles', () {
    test('rejects outputDir outside project root', () async {
      final root = await Directory.systemTemp.createTemp('spry_write_test_');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final config = BuildConfig(rootDir: root.path, outputDir: '..');

      await expectLater(
        () => writeGeneratedFiles(const [], config),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'config.outputDir',
          ),
        ),
      );
    });

    test('rejects generated file path outside output dir', () async {
      final root = await Directory.systemTemp.createTemp('spry_write_test_');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final config = BuildConfig(rootDir: root.path);

      await expectLater(
        () => writeGeneratedFiles([
          const GeneratedFile(path: '../escape.txt', content: 'escape'),
        ], config),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'file.path',
          ),
        ),
      );
      expect(File(p.join(root.path, 'escape.txt')).existsSync(), isFalse);
    });

    test('rejects root-relative file path outside project root', () async {
      final sandbox = await Directory.systemTemp.createTemp('spry_write_test_');
      final root = await Directory(p.join(sandbox.path, 'project')).create();
      addTearDown(() async {
        if (await sandbox.exists()) {
          await sandbox.delete(recursive: true);
        }
      });

      final config = BuildConfig(rootDir: root.path);

      await expectLater(
        () => writeGeneratedFiles([
          const GeneratedFile(
            path: '../escape.txt',
            content: 'escape',
            rootRelative: true,
          ),
        ], config),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'file.path',
          ),
        ),
      );
      expect(File(p.join(sandbox.path, 'escape.txt')).existsSync(), isFalse);
    });

    test('rejects publicDir outside project root for vercel builds', () async {
      final sandbox = await Directory.systemTemp.createTemp('spry_write_test_');
      final root = await Directory(p.join(sandbox.path, 'project')).create();
      addTearDown(() async {
        if (await sandbox.exists()) {
          await sandbox.delete(recursive: true);
        }
      });

      final config = BuildConfig(
        rootDir: root.path,
        target: BuildTarget.vercel,
        publicDir: '..',
      );

      await expectLater(
        () => writeGeneratedFiles(const [], config),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'config.publicDir',
          ),
        ),
      );
    });

    test('rejects publicDir values that include the build output', () async {
      final sandbox = await Directory.systemTemp.createTemp('spry_write_test_');
      final root = await Directory(p.join(sandbox.path, 'project')).create();
      addTearDown(() async {
        if (await sandbox.exists()) {
          await sandbox.delete(recursive: true);
        }
      });

      final config = BuildConfig(
        rootDir: root.path,
        target: BuildTarget.vercel,
        publicDir: '.',
      );

      await expectLater(
        () => writeGeneratedFiles(const [], config),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'config.publicDir',
          ),
        ),
      );
    });

    test(
      'rejects publicDir values that include the build output for netlify builds',
      () async {
        final sandbox = await Directory.systemTemp.createTemp(
          'spry_write_test_',
        );
        final root = await Directory(p.join(sandbox.path, 'project')).create();
        addTearDown(() async {
          if (await sandbox.exists()) {
            await sandbox.delete(recursive: true);
          }
        });

        final config = BuildConfig(
          rootDir: root.path,
          target: BuildTarget.netlify,
          publicDir: '.',
        );

        await expectLater(
          () => writeGeneratedFiles(const [], config),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.name,
              'name',
              'config.publicDir',
            ),
          ),
        );
      },
    );

    test(
      'rejects publicDir values that include the build output for exe builds',
      () async {
        final sandbox = await Directory.systemTemp.createTemp(
          'spry_write_test_',
        );
        final root = await Directory(p.join(sandbox.path, 'project')).create();
        addTearDown(() async {
          if (await sandbox.exists()) {
            await sandbox.delete(recursive: true);
          }
        });

        final config = BuildConfig(
          rootDir: root.path,
          target: BuildTarget.exe,
          publicDir: '.',
        );

        await expectLater(
          () => writeGeneratedFiles(const [], config),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.name,
              'name',
              'config.publicDir',
            ),
          ),
        );
      },
    );
  });
}
