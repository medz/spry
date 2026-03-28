import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';
import 'package:spry/openapi.dart';
import 'package:test/test.dart';

void main() {
  group('BuildConfig', () {
    test('rejects malformed config values', () {
      expect(
        () => BuildConfig.fromJson({
          'target': 'cloudfare',
        }, rootDir: '/tmp/project'),
        throwsA(
          isA<LoadConfigException>().having(
            (error) => error.message,
            'message',
            contains('Invalid `target`'),
          ),
        ),
      );

      expect(
        () => BuildConfig.fromJson({'routesDir': 42}, rootDir: '/tmp/project'),
        throwsA(
          isA<LoadConfigException>().having(
            (error) => error.message,
            'message',
            contains('Invalid `routesDir`'),
          ),
        ),
      );

      expect(
        () => BuildConfig.fromJson({
          'caseSensitive': 42,
        }, rootDir: '/tmp/project'),
        throwsA(
          isA<LoadConfigException>().having(
            (error) => error.message,
            'message',
            contains('Invalid `caseSensitive`'),
          ),
        ),
      );

      expect(
        () => BuildConfig.fromJson({
          'handlerCacheCapacity': 0,
        }, rootDir: '/tmp/project'),
        throwsA(
          isA<LoadConfigException>().having(
            (error) => error.message,
            'message',
            contains('Invalid `handlerCacheCapacity`'),
          ),
        ),
      );
    });

    test('rejects malformed override values', () {
      expect(
        () => const BuildConfig(
          rootDir: '/tmp/project',
        ).merge({'reload': 'restar'}),
        throwsA(
          isA<LoadConfigException>().having(
            (error) => error.message,
            'message',
            contains('Invalid `reload`'),
          ),
        ),
      );
    });

    test('allows clearing wranglerConfig in overrides', () {
      final config = const BuildConfig(
        rootDir: '/tmp/project',
        wranglerConfig: 'wrangler.toml',
      ).merge({'wranglerConfig': null});

      expect(config.wranglerConfig, isNull);
    });
  });

  group('loadConfig', () {
    final fixturesRoot = p.join('test', 'fixtures', 'load_config');

    test(
      'falls back to built-in defaults when spry.config.dart is absent',
      () async {
        final rootDir = p.normalize(p.absolute(fixturesRoot, 'defaults'));
        final config = await loadConfig(overrides: {'rootDir': rootDir});

        expect(config.rootDir, rootDir);
        expect(config.host, '0.0.0.0');
        expect(config.port, 3000);
        expect(config.target, BuildTarget.vm);
        expect(config.routesDir, 'routes');
        expect(config.middlewareDir, 'middleware');
        expect(config.outputDir, '.spry');
        expect(config.reload, ReloadStrategy.restart);
        expect(config.caseSensitive, isTrue);
        expect(config.handlerCacheCapacity, isNull);
      },
    );

    test('reads config from spry.config.dart stdout json', () async {
      final rootDir = p.normalize(p.absolute(fixturesRoot, 'with_config'));
      final config = await loadConfig(overrides: {'rootDir': rootDir});

      expect(config.rootDir, rootDir);
      expect(config.host, '127.0.0.1');
      expect(config.port, 8080);
      expect(config.target, BuildTarget.node);
      expect(config.routesDir, 'app/routes');
      expect(config.middlewareDir, 'app/middleware');
      expect(config.outputDir, 'dist/runtime');
      expect(config.reload, ReloadStrategy.hotswap);
      expect(config.caseSensitive, isFalse);
      expect(config.handlerCacheCapacity, 64);
    });

    test('applies overrides on top of spry.config.dart', () async {
      final rootDir = p.normalize(p.absolute(fixturesRoot, 'with_config'));
      final config = await loadConfig(
        overrides: {
          'rootDir': rootDir,
          'host': '0.0.0.0',
          'port': 3000,
          'target': 'cloudflare',
          'outputDir': '.spry',
          'reload': 'restart',
          'caseSensitive': true,
          'handlerCacheCapacity': 256,
        },
      );

      expect(config.rootDir, rootDir);
      expect(config.host, '0.0.0.0');
      expect(config.port, 3000);
      expect(config.target, BuildTarget.cloudflare);
      expect(config.outputDir, '.spry');
      expect(config.reload, ReloadStrategy.restart);
      expect(config.caseSensitive, isTrue);
      expect(config.handlerCacheCapacity, 256);
    });

    test('accepts deno as a build target override', () async {
      final rootDir = p.normalize(p.absolute(fixturesRoot, 'defaults'));
      final config = await loadConfig(
        overrides: {'rootDir': rootDir, 'target': 'deno'},
      );

      expect(config.rootDir, rootDir);
      expect(config.target, BuildTarget.deno);
    });

    test('reads openapi config from spry.config.dart stdout json', () async {
      final rootDir = p.normalize(p.absolute(fixturesRoot, 'with_openapi'));
      final config = await loadConfig(overrides: {'rootDir': rootDir});

      expect(config.openapi, isNotNull);
      expect(config.openapi!.output.path, 'openapi.json');
      expect(config.openapi!.document.info.title, 'Fixture API');
      expect(config.openapi!.document.info.version, '1.0.0');
      expect(config.openapi!.document.webhooks, {
        'userCreated': isA<OpenAPIPathItem>(),
      });
    });
  });
}
