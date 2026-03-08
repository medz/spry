import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    host: '127.0.0.1',
    port: 8080,
    target: BuildTarget.node,
    routesDir: 'app/routes',
    middlewareDir: 'app/middleware',
    outputDir: 'dist/runtime',
    compileArgs: ['--minify', '--server-mode'],
    reload: ReloadStrategy.hotswap,
  );
}
