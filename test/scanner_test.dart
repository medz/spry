import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/src/builder/config.dart';
import 'package:spry/src/builder/scanner.dart';
import 'package:test/test.dart';

void main() {
  group('scan', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('spry_scanner_test_');
    });

    tearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    test('discovers routes, middleware, errors, hooks and fallback', () async {
      await _write(root, 'routes/index.dart');
      await _write(root, 'routes/about.get.dart');
      await _write(root, 'routes/users/[id].dart');
      await _write(root, 'routes/_middleware.dart');
      await _write(root, 'routes/users/_error.dart');
      await _write(root, 'routes/[...slug].dart');
      await _write(root, 'middleware/01_logger.dart');
      await _write(root, 'middleware/02_auth.dart');
      await _write(root, 'hooks.dart');

      final tree = await scan(BuildConfig(rootDir: root.path));

      expect(tree.hooksPath, p.join(root.path, 'hooks.dart'));
      expect(tree.globalMiddleware.map((it) => it.path), ['/*', '/*']);
      expect(tree.globalMiddleware.map((it) => p.basename(it.filePath)), [
        '01_logger.dart',
        '02_auth.dart',
      ]);

      expect(
        tree.routes.map((it) => (it.path, it.method, p.basename(it.filePath))),
        containsAll([
          ('/', null, 'index.dart'),
          ('/about', 'GET', 'about.get.dart'),
          ('/users/:id', null, '[id].dart'),
        ]),
      );

      expect(tree.scopedMiddleware.single.path, '/*');
      expect(tree.scopedErrors.single.path, '/users/*');

      expect(tree.fallback, isNotNull);
      expect(tree.fallback!.path, '/*');
      expect(tree.fallback!.wildcardParam, 'slug');
    });

    test('rejects duplicate normalized routes', () async {
      await _write(root, 'routes/foo.dart');
      await _write(root, 'routes/foo/index.dart');

      expect(
        () => scan(BuildConfig(rootDir: root.path)),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects param-name drift on the same normalized route', () async {
      await _write(root, 'routes/users/[id].dart');
      await _write(root, 'routes/users/[userId].get.dart');

      expect(
        () => scan(BuildConfig(rootDir: root.path)),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects conflicting catch-all files in the same directory', () async {
      await _write(root, 'routes/[...slug].dart');
      await _write(root, 'routes/[...].dart');

      expect(
        () => scan(BuildConfig(rootDir: root.path)),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects catch-all segments that are not terminal', () async {
      await _write(root, 'routes/[...slug]/index.dart');

      expect(
        () => scan(BuildConfig(rootDir: root.path)),
        throwsA(isA<RouteScanException>()),
      );
    });
  });
}

Future<void> _write(Directory root, String relativePath) async {
  final file = File(p.join(root.path, relativePath));
  await file.parent.create(recursive: true);
  await file.writeAsString('// stub');
}
