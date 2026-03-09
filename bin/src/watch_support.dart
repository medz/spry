import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart' show BuildConfig;
import 'package:watcher/watcher.dart';

Stream<Object> watchServeInputs(
  String rootDir, {
  required BuildConfig Function() currentConfig,
  required String? configPath,
}) {
  final watcher = DirectoryWatcher(rootDir);
  final controller = StreamController<Object>();
  Timer? timer;

  void emit() {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 120), () {
      if (!controller.isClosed) {
        controller.add(Object());
      }
    });
  }

  watcher.events.listen((event) {
    final config = currentConfig();
    final relative = p
        .relative(event.path, from: rootDir)
        .replaceAll('\\', '/');
    if (_isRelevantWatchPath(
      relative,
      config: config,
      configPath: configPath,
    )) {
      emit();
    }
  });

  controller.onCancel = () {
    timer?.cancel();
  };
  return controller.stream;
}

bool _isRelevantWatchPath(
  String relativePath, {
  required BuildConfig config,
  required String? configPath,
}) {
  if (relativePath == '.') {
    return false;
  }

  final normalized = relativePath.replaceAll('\\', '/');
  final outputDir = config.outputDir.replaceAll('\\', '/');
  final routesDir = config.routesDir.replaceAll('\\', '/');
  final middlewareDir = config.middlewareDir.replaceAll('\\', '/');
  final publicDir = config.publicDir.replaceAll('\\', '/');
  final configFile = (configPath ?? 'spry.config.dart').replaceAll('\\', '/');

  if (_isUnder(normalized, outputDir) ||
      _isUnder(normalized, '.dart_tool') ||
      _isUnder(normalized, '.git')) {
    return false;
  }

  return normalized == 'hooks.dart' ||
      normalized == configFile ||
      _isUnder(normalized, routesDir) ||
      _isUnder(normalized, middlewareDir) ||
      _isUnder(normalized, publicDir);
}

bool _isUnder(String path, String prefix) {
  return path == prefix || path.startsWith('$prefix/');
}
