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

      expect(tree.hooks, isNotNull);
      expect(tree.hooks!.filePath, p.join(root, 'hooks.dart'));
      expect(tree.hooks!.hasOnStart, isTrue);
      expect(tree.hooks!.hasOnStop, isFalse);
      expect(tree.hooks!.hasOnError, isFalse);
      expect(
        tree.globalMiddleware.map(
          (it) => (it.path, it.method, p.basename(it.filePath)),
        ),
        [
          ('/**', null, '01_logger.dart'),
          ('/**', HttpMethod.get, '02_auth.get.dart'),
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
          ('/**', null, '_middleware.dart'),
          ('/users/**', HttpMethod.get, '_middleware.get.dart'),
        ],
      );
      expect(
        tree.scopedErrors.map(
          (it) => (it.path, it.method, p.basename(it.filePath)),
        ),
        [
          ('/users/**', null, '_error.dart'),
          ('/users/**', HttpMethod.get, '_error.get.dart'),
        ],
      );

      expect(tree.fallback, isNotNull);
      expect(tree.fallback!.path, '/**:slug');
      expect(tree.fallback!.wildcardParam, 'slug');
    });

    test('supports expressive route segment syntax', () async {
      final tree = await scan(BuildConfig(rootDir: _fixture('expressive')));

      expect(
        tree.routes.map((it) => (it.path, it.method, p.basename(it.filePath))),
        containsAll([
          ('/users/*', null, '[_].dart'),
          ('/users/:id([0-9]+)', null, '[id([0-9]+)].dart'),
          ('/files/:name.:ext', null, '[name].[ext].dart'),
          ('/posts/post-:id.json', HttpMethod.get, 'post-[id].json.get.dart'),
          ('/docs/:section?', null, '[[section]].dart'),
          ('/assets/:path+', null, '[...path+].dart'),
          ('/archive/:rest*', null, '[[...rest]].dart'),
        ]),
      );
    });

    test('ignores hook names in comments, strings and method calls', () async {
      final root = _fixture('false_positive_hooks');
      final tree = await scan(BuildConfig(rootDir: root));

      expect(tree.hooks, isNotNull);
      expect(tree.hooks!.hasOnStart, isFalse);
      expect(tree.hooks!.hasOnStop, isFalse);
      expect(tree.hooks!.hasOnError, isFalse);
    });

    test('rejects duplicate normalized routes', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('duplicate_routes'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('rejects duplicate param names inside one route', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('duplicate_param_names'))),
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

    test('rejects named catch-all param-name drift', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('catch_all_name_drift'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('preserves literal index directories for scoped handlers', () async {
      final tree = await scan(
        BuildConfig(rootDir: _fixture('scoped_index_dir')),
      );

      expect(
        tree.scopedMiddleware.map((it) => (it.path, p.basename(it.filePath))),
        [('/index/**', '_middleware.dart')],
      );
      expect(
        tree.scopedErrors.map((it) => (it.path, p.basename(it.filePath))),
        [('/index/**', '_error.dart')],
      );
    });

    test('rejects catch-all segments that are not terminal', () async {
      expect(
        () => scan(BuildConfig(rootDir: _fixture('non_terminal_catch_all'))),
        throwsA(isA<RouteScanException>()),
      );
    });

    test('allows catch-all directories when index.dart is terminal', () async {
      final tree = await scan(
        BuildConfig(rootDir: _fixture('catch_all_index_dir')),
      );

      expect(tree.routes.map((it) => (it.path, p.basename(it.filePath))), [
        ('/docs/**:slug', 'index.dart'),
      ]);
    });
  });
}

String _fixture(String name) {
  return p.normalize(p.absolute('test', 'fixtures', 'scanner', name));
}
