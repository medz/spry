import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    port: 3000,
    target: BuildTarget.netlify,
    reload: ReloadStrategy.hotswap,
  );
}
