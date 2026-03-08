import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';
import 'package:test/test.dart';

void main() {
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
        expect(config.compileArgs, isEmpty);
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
      expect(config.compileArgs, ['--minify', '--server-mode']);
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
          'compileArgs': ['--native-null-assertions'],
          'reload': 'restart',
        },
      );

      expect(config.rootDir, rootDir);
      expect(config.host, '0.0.0.0');
      expect(config.port, 3000);
      expect(config.target, BuildTarget.cloudflare);
      expect(config.outputDir, '.spry');
      expect(config.compileArgs, ['--native-null-assertions']);
      expect(config.reload, ReloadStrategy.restart);
    });
  });
}
