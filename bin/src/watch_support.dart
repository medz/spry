import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart' show BuildConfig;
import 'package:watcher/watcher.dart';

Stream<String> watchServeInputs(
  String rootDir, {
  required BuildConfig Function() currentConfig,
  required String? configPath,
  Set<String> Function()? generatedSourcePaths,
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
      final relative = p.normalize(p.relative(event.path, from: rootDir));
      final excluded = generatedSourcePaths?.call() ?? const {};
      if (excluded.contains(relative)) {
        return;
      }
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
  return p.normalize(
    p.relative(
      p.absolute(rootDir, configPath ?? 'spry.config.dart'),
      from: rootDir,
    ),
  );
}

bool _isRelevantWatchPath(
  String relativePath, {
  required BuildConfig config,
  required String? configPath,
}) {
  if (relativePath == '.') {
    return false;
  }

  if (p.isWithin(config.outputDir, relativePath) ||
      p.equals(config.outputDir, relativePath) ||
      p.isWithin('.spry', relativePath) ||
      p.equals('.spry', relativePath) ||
      p.isWithin('.dart_tool', relativePath) ||
      p.equals('.dart_tool', relativePath) ||
      p.isWithin('.git', relativePath) ||
      p.equals('.git', relativePath)) {
    return false;
  }

  return p.equals(relativePath, 'hooks.dart') ||
      p.equals(relativePath, configPath ?? 'spry.config.dart') ||
      p.isWithin(config.routesDir, relativePath) ||
      p.equals(relativePath, config.routesDir) ||
      p.isWithin(config.middlewareDir, relativePath) ||
      p.equals(relativePath, config.middlewareDir) ||
      p.isWithin(config.publicDir, relativePath) ||
      p.equals(relativePath, config.publicDir);
}
