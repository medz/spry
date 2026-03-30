import 'package:path/path.dart' as p;
import 'package:spry/src/public/native_path.dart';
import 'package:test/test.dart';

void main() {
  group('resolveNativeChildPath', () {
    test('allows paths within a relative root', () {
      expect(
        resolveNativeChildPath('.', 'hello.txt', style: p.Style.posix),
        'hello.txt',
      );
      expect(
        resolveNativeChildPath('.', 'nested/index.html', style: p.Style.posix),
        'nested/index.html',
      );
    });

    test('rejects traversal outside a relative root', () {
      expect(
        resolveNativeChildPath('.', '../secret.txt', style: p.Style.posix),
        isNull,
      );
      expect(
        resolveNativeChildPath('public', '../secret.txt', style: p.Style.posix),
        isNull,
      );
    });

    test('preserves absolute roots', () {
      expect(
        resolveNativeChildPath(
          '/workspace/public',
          'hello.txt',
          style: p.Style.posix,
        ),
        '/workspace/public/hello.txt',
      );
    });

    test('preserves windows drive roots', () {
      expect(
        resolveNativeChildPath(
          r'C:\workspace\public',
          'hello.txt',
          style: p.Style.windows,
        ),
        r'C:\workspace\public\hello.txt',
      );
    });

    test('preserves windows style for relative paths', () {
      expect(
        resolveNativeChildPath('public', 'hello.txt', style: p.Style.windows),
        r'public\hello.txt',
      );
    });
  });
}
