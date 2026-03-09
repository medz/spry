import 'package:path/path.dart' as p;
import 'package:spry/config.dart';
import 'package:spry/src/builder/config.dart';
import 'package:spry/src/builder/generator.dart';
import 'package:spry/src/builder/scanner.dart';
import 'package:test/test.dart';

void main() {
  group('generate', () {
    test('generates app.dart from scanned files', () async {
      final config = BuildConfig(rootDir: _fixture('complete'));
      final tree = await scan(config);
      final files = await generate(tree, config);

      expect(
        files.map((it) => it.path),
        containsAll(['app.dart', 'hooks.dart', 'main.dart']),
      );

      final content = files.singleWhere((it) => it.path == 'app.dart').content;
      expect(content, contains("import 'package:spry/src/app.dart';"));
      expect(content, contains("import 'package:spry/src/error_route.dart';"));
      expect(content, contains("import 'package:spry/src/middleware.dart';"));

      expect(content, contains("import '../middleware/01_logger.dart'"));
      expect(content, contains("import '../middleware/02_auth.get.dart'"));
      expect(content, contains("import '../routes/index.dart'"));
      expect(content, contains("import '../routes/about.get.dart'"));
      expect(content, contains("import '../routes/users/[id].dart'"));
      expect(content, contains("import '../routes/_middleware.dart'"));
      expect(
        content,
        contains("import '../routes/users/_middleware.get.dart'"),
      );
      expect(content, contains("import '../routes/users/_error.dart'"));
      expect(content, contains("import '../routes/users/_error.get.dart'"));
      expect(content, contains("import '../routes/[...slug].dart'"));

      expect(content, contains('final app = Spry('));
      expect(content, contains("'/'"));
      expect(content, contains("null: "));
      expect(content, contains("HttpMethod.get: "));
      expect(content, contains("'/users/:id'"));
      expect(content, contains("MiddlewareRoute(path: '/*', handler:"));
      expect(
        content,
        contains("MiddlewareRoute(path: '/*', method: HttpMethod.get"),
      );
      expect(
        content,
        contains("MiddlewareRoute(path: '/users/*', method: HttpMethod.get"),
      );
      expect(content, contains("ErrorRoute(path: '/users/*', handler:"));
      expect(
        content,
        contains("ErrorRoute(path: '/users/*', method: HttpMethod.get"),
      );
      expect(content, contains('fallback: {'));
      expect(content, contains("publicDir: 'public'"));

      final hooks = files.singleWhere((it) => it.path == 'hooks.dart').content;
      expect(hooks, contains("import '../hooks.dart' as \$source;"));
      expect(hooks, contains('final onStart = \$source.onStart;'));
      expect(hooks, contains('final onStop = null;'));
      expect(hooks, contains('final onError = null;'));

      final main = files.singleWhere((it) => it.path == 'main.dart').content;
      expect(main, contains("import 'package:osrv/osrv.dart';"));
      expect(main, contains("import 'package:osrv/runtime/dart.dart';"));
      expect(main, contains("import 'hooks.dart' as \$hooks;"));
      expect(main, contains("import 'app.dart';"));
      expect(main, contains('fetch: app.fetch,'));
      expect(main, contains("DartRuntimeConfig(host: '0.0.0.0', port: 3000)"));
    });

    test('uses outputDir when computing relative imports', () async {
      final config = BuildConfig(
        rootDir: _fixture('complete'),
        outputDir: 'generated/runtime',
      );
      final tree = await scan(config);
      final files = await generate(tree, config);

      expect(
        files.singleWhere((it) => it.path == 'app.dart').content,
        contains("import '../../routes/index.dart'"),
      );
    });

    test('generates null hook stubs when hooks.dart is absent', () async {
      final config = BuildConfig(rootDir: _fixture('no_hooks'));
      final tree = await scan(config);
      final files = await generate(tree, config);

      final hooks = files.singleWhere((it) => it.path == 'hooks.dart').content;
      expect(hooks, contains('final onStart = null;'));
      expect(hooks, contains('final onStop = null;'));
      expect(hooks, contains('final onError = null;'));
    });

    test('generates node main.dart for node target', () async {
      final config = BuildConfig(
        rootDir: _fixture('no_hooks'),
        target: BuildTarget.node,
      );
      final tree = await scan(config);
      final files = await generate(tree, config);

      final main = files.singleWhere((it) => it.path == 'main.dart').content;
      expect(main, contains("import 'package:osrv/runtime/node.dart';"));
      expect(main, contains('fetch: app.fetch,'));
      expect(main, contains("NodeRuntimeConfig(host: '0.0.0.0', port: 3000)"));

      final entry = files.singleWhere((it) => it.path == 'main.cjs').content;
      expect(entry, contains('globalThis.self ??= globalThis;'));
      expect(entry, contains("require('./runtime/main.js');"));
    });

    test('generates cloudflare main.dart with esm thin layer', () async {
      final config = BuildConfig(
        rootDir: _fixture('no_hooks'),
        target: BuildTarget.cloudflare,
      );
      final tree = await scan(config);
      final files = await generate(tree, config);

      expect(files.map((it) => it.path), contains('cloudflare.mjs'));
      expect(
        files.singleWhere((it) => it.path == 'app.dart').content,
        isNot(contains('publicDir:')),
      );

      final main = files.singleWhere((it) => it.path == 'main.dart').content;
      expect(
        main,
        contains("import 'package:spry/src/runtime/cloudflare_entry.dart' as \$entry;"),
      );
      expect(
        main,
        contains(r'$entry.defineCloudflareFetchEntry(server);'),
      );

      final worker = files
          .singleWhere((it) => it.path == 'cloudflare.mjs')
          .content;
      expect(worker, contains("import './main.js';"));
      expect(
        worker,
        contains('export default { fetch: globalThis.__osrv_fetch__ };'),
      );
    });

    test('generates vercel main.dart with esm thin layer', () async {
      final config = BuildConfig(
        rootDir: _fixture('no_hooks'),
        target: BuildTarget.vercel,
      );
      final tree = await scan(config);
      final files = await generate(tree, config);

      expect(
        files.map((it) => (path: it.path, root: it.rootRelative)),
        containsAll([
          (path: 'vercel/api/index.mjs', root: false),
          (path: 'vercel/vercel.json', root: false),
          (path: 'vercel/package.json', root: false),
        ]),
      );

      final main = files.singleWhere((it) => it.path == 'main.dart').content;
      expect(
        main,
        contains("import 'package:spry/src/runtime/vercel_entry.dart' as \$entry;"),
      );
      expect(main, contains(r'$entry.defineVercelFetchEntry(server);'));

      final entry = files
          .singleWhere((it) => it.path == 'vercel/api/index.mjs')
          .content;
      expect(entry, contains('globalThis.self ??= globalThis;'));
      expect(entry, contains("import '../runtime/main.js';"));
      expect(
        entry,
        contains('export default { fetch: globalThis.__osrv_fetch__ };'),
      );

      final vercelConfig = files.singleWhere(
        (it) => it.path == 'vercel/vercel.json',
      );
      expect(vercelConfig.writeIfMissing, isFalse);
      expect(vercelConfig.content, contains('"destination": "/api"'));
      final packageJson = files.singleWhere(
        (it) => it.path == 'vercel/package.json',
      );
      expect(packageJson.content, contains('"@vercel/functions"'));
    });
  });
}

String _fixture(String name) {
  return p.normalize(p.absolute('test', 'fixtures', 'generator', name));
}
