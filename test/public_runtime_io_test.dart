import 'dart:io' as io;

import 'package:osrv/osrv.dart';
import 'package:spry/src/public_runtime_io.dart' as runtime;
import 'package:test/test.dart';

void main() {
  group('resolvePublicAsset (io)', () {
    test('returns null when relative path escapes public dir', () async {
      final root = await io.Directory.systemTemp.createTemp(
        'spry_public_runtime_io_test_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final publicDir = io.Directory('${root.path}/public');
      await publicDir.create(recursive: true);
      await io.File('${root.path}/secret.txt').writeAsString('secret');

      final asset = await runtime.resolvePublicAsset(
        Request(Uri.parse('https://example.com/secret.txt')),
        _context(),
        publicDir: publicDir.path,
        relativePath: '../secret.txt',
        includeBody: true,
      );

      expect(asset, isNull);
    });

    test('serves files within public dir', () async {
      final root = await io.Directory.systemTemp.createTemp(
        'spry_public_runtime_io_test_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final publicDir = io.Directory('${root.path}/public');
      await publicDir.create(recursive: true);
      await io.File('${publicDir.path}/hello.txt').writeAsString('hello');

      final asset = await runtime.resolvePublicAsset(
        Request(Uri.parse('https://example.com/hello.txt')),
        _context(),
        publicDir: publicDir.path,
        relativePath: 'hello.txt',
        includeBody: true,
      );

      expect(asset, isNotNull);
      expect(asset!.headers.get('content-length'), '5');
    });
  });
}

RequestContext _context() {
  return RequestContext(
    runtime: const RuntimeInfo(name: 'test', kind: 'server'),
    capabilities: const RuntimeCapabilities(
      streaming: true,
      websocket: false,
      fileSystem: true,
      backgroundTask: true,
      rawTcp: false,
      nodeCompat: false,
    ),
    onWaitUntil: (_) {},
  );
}
