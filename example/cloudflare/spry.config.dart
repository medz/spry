import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    host: '127.0.0.1',
    port: 8787,
    target: BuildTarget.cloudflare,
    reload: ReloadStrategy.hotswap,
  );
}
