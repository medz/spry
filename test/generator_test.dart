import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:spry/config.dart';
import 'package:spry/openapi.dart';
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
        containsAll(['src/app.dart', 'src/hooks.dart', 'src/main.dart']),
      );

      final content = files
          .singleWhere((it) => it.path == 'src/app.dart')
          .content;
      expect(
        content,
        contains(
          "import 'package:spry/spry.dart' show Spry, ErrorRoute, MiddlewareRoute;",
        ),
      );
      expect(
        content,
        contains("import 'package:spry/spry.dart' show HttpMethod;"),
      );
      expect(
        content,
        isNot(
          contains(
            "import 'package:spry/spry.dart' show Event, Handler, RouteParams;",
          ),
        ),
      );

      expect(content, contains("import '../../middleware/01_logger.dart'"));
      expect(content, contains("import '../../middleware/02_auth.get.dart'"));
      expect(content, contains("import '../../routes/index.dart'"));
      expect(content, contains("import '../../routes/about.get.dart'"));
      expect(content, contains("import '../../routes/users/[id].dart'"));
      expect(content, contains("import '../../routes/_middleware.dart'"));
      expect(
        content,
        contains("import '../../routes/users/_middleware.get.dart'"),
      );
      expect(content, contains("import '../../routes/users/_error.dart'"));
      expect(content, contains("import '../../routes/users/_error.get.dart'"));
      expect(content, contains("import '../../routes/[...slug].dart'"));

      expect(content, contains('final app = Spry('));
      expect(content, contains("'/'"));
      expect(content, contains("null: "));
      expect(content, contains("HttpMethod.get: "));
      expect(content, contains("'/users/:id'"));
      expect(content, isNot(contains('Handler _withWildcardParam(')));
      expect(content, isNot(contains("'wildcard': value,")));
      expect(content, contains("MiddlewareRoute(path: '/**', handler:"));
      expect(
        content,
        contains("MiddlewareRoute(path: '/**', method: HttpMethod.get"),
      );
      expect(
        content,
        contains("MiddlewareRoute(path: '/users/**', method: HttpMethod.get"),
      );
      expect(content, contains("ErrorRoute(path: '/users/**', handler:"));
      expect(
        content,
        contains("ErrorRoute(path: '/users/**', method: HttpMethod.get"),
      );
      expect(content, contains('fallback: {'));
      expect(content, contains("publicDir: 'public'"));

      final hooks = files
          .singleWhere((it) => it.path == 'src/hooks.dart')
          .content;
      expect(hooks, contains("import '../../hooks.dart' as \$source;"));
      expect(hooks, contains('final onStart = \$source.onStart;'));
      expect(hooks, contains('final onStop = null;'));
      expect(hooks, contains('final onError = null;'));

      final main = files
          .singleWhere((it) => it.path == 'src/main.dart')
          .content;
      expect(main, contains("import 'package:spry/osrv.dart';"));
      expect(main, contains("import 'package:spry/osrv/dart.dart';"));
      expect(main, contains("import 'hooks.dart' as \$hooks;"));
      expect(main, contains("import 'app.dart';"));
      expect(main, contains('fetch: app.fetch,'));
      expect(main, contains("host: '0.0.0.0'"));
      expect(main, contains('port: 3000'));
    });

    test('uses outputDir when computing relative imports', () async {
      final config = BuildConfig(
        rootDir: _fixture('complete'),
        outputDir: 'generated/runtime',
      );
      final tree = await scan(config);
      final files = await generate(tree, config);

      expect(
        files.singleWhere((it) => it.path == 'src/app.dart').content,
        contains("import '../../../routes/index.dart'"),
      );
    });

    test('generates null hook stubs when hooks.dart is absent', () async {
      final config = BuildConfig(rootDir: _fixture('no_hooks'));
      final tree = await scan(config);
      final files = await generate(tree, config);

      final hooks = files
          .singleWhere((it) => it.path == 'src/hooks.dart')
          .content;
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

      final main = files
          .singleWhere((it) => it.path == 'src/main.dart')
          .content;
      expect(main, contains("import 'package:spry/osrv/node.dart';"));
      expect(main, contains('fetch: app.fetch,'));
      expect(main, contains("host: '0.0.0.0'"));
      expect(main, contains('port: 3000'));

      final entry = files
          .singleWhere((it) => it.path == 'node/index.cjs')
          .content;
      expect(entry, contains('globalThis.self ??= globalThis;'));
      expect(entry, contains("require('./runtime/main.js');"));
    });

    test('generates deno main.dart for deno target', () async {
      final config = BuildConfig(
        rootDir: _fixture('no_hooks'),
        target: BuildTarget.deno,
      );
      final tree = await scan(config);
      final files = await generate(tree, config);

      final main = files
          .singleWhere((it) => it.path == 'src/main.dart')
          .content;
      expect(main, contains("import 'package:spry/osrv/deno.dart';"));
      expect(main, contains('fetch: app.fetch,'));
      expect(main, contains("host: '0.0.0.0'"));
      expect(main, contains('port: 3000'));
      expect(files.map((it) => it.path), isNot(contains('node/index.cjs')));
    });

    test('generates cloudflare main.dart with esm thin layer', () async {
      final config = BuildConfig(
        rootDir: _fixture('no_hooks'),
        target: BuildTarget.cloudflare,
      );
      final tree = await scan(config);
      final files = await generate(tree, config);

      expect(files.map((it) => it.path), contains('cloudflare/index.js'));
      expect(
        files.singleWhere((it) => it.path == 'src/app.dart').content,
        isNot(contains('publicDir:')),
      );

      final main = files
          .singleWhere((it) => it.path == 'src/main.dart')
          .content;
      expect(
        main,
        contains("import 'package:spry/osrv/cloudflare.dart' as \$entry;"),
      );
      expect(main, contains(r'$entry.defineFetchExport(server);'));

      final worker = files
          .singleWhere((it) => it.path == 'cloudflare/index.js')
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

      final main = files
          .singleWhere((it) => it.path == 'src/main.dart')
          .content;
      expect(
        main,
        contains("import 'package:spry/osrv/vercel.dart' as \$entry;"),
      );
      expect(main, contains(r'$entry.defineFetchExport(server);'));

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

    test('generates netlify main.dart with functions workspace', () async {
      final config = BuildConfig(
        rootDir: _fixture('no_hooks'),
        target: BuildTarget.netlify,
      );
      final tree = await scan(config);
      final files = await generate(tree, config);

      expect(
        files.map((it) => (path: it.path, root: it.rootRelative)),
        containsAll([
          (path: 'netlify/functions/index.mjs', root: false),
          (path: 'netlify/netlify.toml', root: false),
        ]),
      );

      final main = files
          .singleWhere((it) => it.path == 'src/main.dart')
          .content;
      expect(
        main,
        contains("import 'package:spry/osrv/netlify.dart' as \$entry;"),
      );
      expect(main, contains(r'$entry.defineFetchExport(server);'));

      final entry = files
          .singleWhere((it) => it.path == 'netlify/functions/index.mjs')
          .content;
      expect(entry, contains('globalThis.self ??= globalThis;'));
      expect(entry, contains("import '../runtime/main.js';"));
      expect(entry, contains('export default globalThis.__osrv_fetch__;'));

      final netlifyToml = files.singleWhere(
        (it) => it.path == 'netlify/netlify.toml',
      );
      expect(netlifyToml.content, contains('publish = "public"'));
      expect(netlifyToml.content, contains('directory = "functions"'));
      expect(netlifyToml.content, contains('to = "/.netlify/functions/index"'));
    });

    test(
      'generates openapi.json with converted paths and expanded methods',
      () async {
        final config = BuildConfig(
          rootDir: _fixture('with_openapi'),
          openapi: OpenAPIConfig(
            document: OpenAPIDocumentConfig(
              info: OpenAPIInfo(title: 'Fixture API', version: '1.0.0'),
            ),
          ),
        );
        final tree = await scan(config);
        final files = await generate(tree, config);

        final openapiFile = files.singleWhere(
          (file) => file.path == 'public/openapi.json',
        );
        expect(openapiFile.rootRelative, isTrue);

        final document =
            jsonDecode(openapiFile.content) as Map<String, dynamic>;
        expect(document['openapi'], '3.1.0');
        expect(document['info'], {'title': 'Fixture API', 'version': '1.0.0'});

        final paths = document['paths'] as Map<String, dynamic>;
        expect(paths.keys, containsAll(['/', '/users/{id}']));
        expect(
          paths['/'] as Map<String, dynamic>,
          containsPair('get', {'summary': 'Home'}),
        );

        final userPath = paths['/users/{id}'] as Map<String, dynamic>;
        expect(userPath['get'], {'summary': 'Get user'});
        expect(userPath['post'], {'summary': 'Any user op'});
        expect(userPath['put'], {'summary': 'Any user op'});
        expect(userPath['patch'], {'summary': 'Any user op'});
        expect(userPath['delete'], {'summary': 'Any user op'});
        expect(userPath['options'], {'summary': 'Any user op'});
        expect(userPath, isNot(contains('head')));
      },
    );
  });
}

String _fixture(String name) {
  return p.normalize(p.absolute('test', 'fixtures', 'generator', name));
}
