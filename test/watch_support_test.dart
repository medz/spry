import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:test/test.dart';

import '../bin/src/watch_support.dart';

void main() {
  group('watchServeInputs', () {
    test('watches config file when path uses dot-relative input', () async {
      final root = await Directory.systemTemp.createTemp(
        'spry_watch_support_test_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configFile = File(p.join(root.path, 'spry.config.dart'));
      await configFile.writeAsString('// config');

      final stream = watchServeInputs(
        root.path,
        currentConfig: () => BuildConfig(rootDir: root.path),
        configPath: './spry.config.dart',
      );
      final nextEvent = stream.first.timeout(const Duration(seconds: 3));

      await _allowWatcherToStart();
      await configFile.writeAsString('// updated');

      await expectLater(nextEvent, completion(isA<Object>()));
    });

    test('watches config file when path uses an absolute input', () async {
      final root = await Directory.systemTemp.createTemp(
        'spry_watch_support_test_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final configFile = File(p.join(root.path, 'configs', 'serve.dart'));
      await configFile.parent.create(recursive: true);
      await configFile.writeAsString('// config');

      final stream = watchServeInputs(
        root.path,
        currentConfig: () => BuildConfig(rootDir: root.path),
        configPath: configFile.path,
      );
      final nextEvent = stream.first.timeout(const Duration(seconds: 3));

      await _allowWatcherToStart();
      await configFile.writeAsString('// updated');

      await expectLater(nextEvent, completion(isA<Object>()));
    });
  });
}

Future<void> _allowWatcherToStart() {
  return Future<void>.delayed(const Duration(milliseconds: 250));
}
