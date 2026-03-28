import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart' show BuildConfig;
import 'package:watcher/watcher.dart';

Stream<String> watchServeInputs(
  String rootDir, {
  required BuildConfig Function() currentConfig,
  required String? configPath,
}) {
  final watcher = DirectoryWatcher(rootDir);
  final controller = StreamController<String>();
  final watchedConfigPath = _normalizeConfigWatchPath(rootDir, configPath);
  Timer? timer;
  StreamSubscription<WatchEvent>? subscription;
  String? lastPath;
  var changeCount = 0;

  void emit() {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 120), () {
      if (!controller.isClosed) {
        final payload = changeCount == 1 ? lastPath! : '$changeCount files';
        lastPath = null;
        changeCount = 0;
        controller.add(payload);
      }
    });
  }

  controller.onListen = () {
    subscription = watcher.events.listen((event) {
      final config = currentConfig();
      final relative = p
          .relative(event.path, from: rootDir)
          .replaceAll('\\', '/');
      if (_isRelevantWatchPath(
        relative,
        config: config,
        configPath: watchedConfigPath,
      )) {
        lastPath = relative;
        changeCount++;
        emit();
      }
    }, onError: controller.addError);
  };

  controller.onCancel = () async {
    timer?.cancel();
    await subscription?.cancel();
    subscription = null;
  };
  return controller.stream;
}

String _normalizeConfigWatchPath(String rootDir, String? configPath) {
  final path = p.absolute(rootDir, configPath ?? 'spry.config.dart');
  return p.relative(path, from: rootDir).replaceAll('\\', '/');
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
