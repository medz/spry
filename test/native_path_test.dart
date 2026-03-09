import 'package:spry/src/native_path.dart';
import 'package:test/test.dart';

void main() {
  group('resolveNativeChildPath', () {
    test('allows paths within a relative root', () {
      expect(resolveNativeChildPath('.', 'hello.txt'), 'hello.txt');
      expect(
        resolveNativeChildPath('.', 'nested/index.html'),
        'nested/index.html',
      );
    });

    test('rejects traversal outside a relative root', () {
      expect(resolveNativeChildPath('.', '../secret.txt'), isNull);
      expect(resolveNativeChildPath('public', '../secret.txt'), isNull);
    });

    test('preserves absolute roots', () {
      expect(
        resolveNativeChildPath('/workspace/public', 'hello.txt'),
        '/workspace/public/hello.txt',
      );
    });

    test('preserves windows drive roots', () {
      expect(
        resolveNativeChildPath(r'C:\workspace\public', 'hello.txt'),
        r'C:\workspace\public\hello.txt',
      );
    });
  });
}
