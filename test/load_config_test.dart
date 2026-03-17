import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';
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
        expect(config.target, BuildTarget.dart);
        expect(config.routesDir, 'routes');
        expect(config.middlewareDir, 'middleware');
        expect(config.outputDir, '.spry');
        expect(config.reload, ReloadStrategy.restart);
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
        },
      );

      expect(config.rootDir, rootDir);
      expect(config.host, '0.0.0.0');
      expect(config.port, 3000);
      expect(config.target, BuildTarget.cloudflare);
      expect(config.outputDir, '.spry');
      expect(config.reload, ReloadStrategy.restart);
    });
  });
}
