import 'package:path/path.dart' as p;
import 'package:spry/spry.dart' show HttpMethod;
import 'package:spry/src/builder/config.dart';
import 'package:spry/src/builder/scanner.dart';
import 'package:test/test.dart';

void main() {
  group('scan', () {
    test('discovers routes, middleware, errors, hooks and fallback', () async {
      final root = _fixture('complete');
      final tree = await scan(BuildConfig(rootDir: root));

      expect(tree.hooksPath, p.join(root, 'hooks.dart'));
      expect(
        tree.globalMiddleware.map(
          (it) => (it.path, it.method, p.basename(it.filePath)),
        ),
        [
          ('/*', null, '01_logger.dart'),
          ('/*', HttpMethod.get, '02_auth.get.dart'),
        ],
      );

      expect(
        tree.routes.map((it) => (it.path, it.method, p.basename(it.filePath))),
        containsAll([
          ('/', null, 'index.dart'),
          ('/about', HttpMethod.get, 'about.get.dart'),
          ('/users/:id', null, '[id].dart'),
        ]),
      );

      expect(
        tree.scopedMiddleware.map(
          (it) => (it.path, it.method, p.basename(it.filePath)),
        ),
        [
          ('/*', null, '_middleware.dart'),
          ('/users/*', HttpMethod.get, '_middleware.get.dart'),
        ],
      );
      expect(
        tree.scopedErrors.map(
          (it) => (it.path, it.method, p.basename(it.filePath)),
        ),
        [
          ('/users/*', null, '_error.dart'),
          ('/users/*', HttpMethod.get, '_error.get.dart'),
        ],
      );

      expect(tree.fallback, isNotNull);
      expect(tree.fallback!.path, '/*');
      expect(tree.fallback!.wildcardParam, 'slug');
    });

    test('rejects duplicate normalized routes', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('duplicate_routes'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects param-name drift on the same normalized route', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('param_name_drift'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects conflicting catch-all files in the same directory', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('conflicting_catch_all'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects catch-all segments that are not terminal', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('non_terminal_catch_all'))),
        throwsA(isA<RouteScanException>()),
      );
    });
  });
}

String _fixture(String name) {
  return p.normalize(p.absolute('test', 'fixtures', 'scanner', name));
}
