import 'package:spry/config.dart';

void main() {
  defineSpryConfig(
    host: '127.0.0.1',
    port: 4020,
    target: BuildTarget.vm,
    client: .new(pkgDir: '../client', endpoint: 'http://127.0.0.1:4020'),
  );
}
