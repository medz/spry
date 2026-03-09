import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart' show BuildConfig, loadConfig;
import 'package:spry/config.dart';
import 'package:watcher/watcher.dart';

import 'build_pipeline.dart';
import 'runtime_runner.dart';
import 'tools/bun.dart';

typedef ProcessStarter =
    Future<Process> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      Map<String, String>? environment,
      bool includeParentEnvironment,
      bool runInShell,
      ProcessStartMode mode,
    });

Future<int> runServe(
  String cwd,
  Args args,
  StringSink out,
  StringSink err, {
  ProcessRunner processRunner = Process.run,
  ProcessStarter processStarter = Process.start,
  BunInstaller? installBun,
  Stream<Object>? watchEvents,
}) async {
  final configPath = _string(args, 'config');

  try {
    var config = await loadConfig(
      configPath: configPath,
      overrides: {'rootDir': cwd},
    );
    final events =
        watchEvents ??
        _watchServeInputs(
          config.rootDir,
          currentConfig: () => config,
          configPath: configPath,
        );
    final changes = StreamIterator(events);

    var session = await _buildAndStart(
      config,
      out: out,
      err: err,
      processRunner: processRunner,
      processStarter: processStarter,
      installBun: installBun,
    );

    while (true) {
      final result = await Future.any<Object>([
        changes.moveNext(),
        session.process.exitCode,
      ]);

      if (result is int) {
        return result;
      }
      if (result != true) {
        return await session.process.exitCode;
      }

      BuildConfig nextConfig;
      try {
        nextConfig = await loadConfig(
          configPath: configPath,
          overrides: {'rootDir': cwd},
        );
      } catch (error) {
        err.writeln(error);
        continue;
      }

      final nextBuild = await _tryBuild(
        nextConfig,
        err: err,
        out: out,
        processRunner: processRunner,
        installBun: installBun,
      );
      if (nextBuild == null) {
        continue;
      }

      final canHotSwap =
          nextConfig.reload == ReloadStrategy.hotswap &&
          nextBuild.supportsHotSwap &&
          sameRunnerSpec(session.spec, nextBuild.spec);

      config = nextConfig;
      if (canHotSwap) {
        out.writeln('Rebuilt ${nextConfig.outputDir}');
        continue;
      }

      session.process.kill();
      await session.process.exitCode;
      session = await _startRunner(
        nextBuild.spec,
        processStarter: processStarter,
      );
      out.writeln('Restarted ${config.target.name}');
    }
  } catch (error) {
    err.writeln(error);
    return 1;
  }
}

Future<_ServeSession> _buildAndStart(
  BuildConfig config, {
  required StringSink out,
  required StringSink err,
  required ProcessRunner processRunner,
  required ProcessStarter processStarter,
  required BunInstaller? installBun,
}) async {
  final build = await _prepareServeBuild(
    config,
    out: out,
    processRunner: processRunner,
    installBun: installBun,
  );
  out.writeln('Serving ${config.target.name} from ${config.outputDir}');
  return _startRunner(build.spec, processStarter: processStarter);
}

Future<ServePlan?> _tryBuild(
  BuildConfig config, {
  required StringSink err,
  required StringSink out,
  required ProcessRunner processRunner,
  required BunInstaller? installBun,
}) async {
  try {
    return await _prepareServeBuild(
      config,
      out: out,
      processRunner: processRunner,
      installBun: installBun,
    );
  } catch (error) {
    err.writeln(error);
    return null;
  }
}

Future<ServePlan> _prepareServeBuild(
  BuildConfig config, {
  required StringSink out,
  required ProcessRunner processRunner,
  required BunInstaller? installBun,
}) async {
  final build = await buildProject(
    config,
    out: out,
    processRunner: processRunner,
  );
  return createServePlan(
    build,
    processRunner: processRunner,
    installBun: installBun,
  );
}

Future<_ServeSession> _startRunner(
  RunnerSpec spec, {
  required ProcessStarter processStarter,
}) async {
  final process = await processStarter(
    spec.executable,
    spec.arguments,
    workingDirectory: spec.workingDirectory,
    runInShell: Platform.isWindows,
    mode: ProcessStartMode.inheritStdio,
    includeParentEnvironment: true,
  );
  return _ServeSession(spec: spec, process: process);
}

Stream<Object> _watchServeInputs(
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

String? _string(Args args, String key) => args[key]?.safeAs<String>();

final class _ServeSession {
  const _ServeSession({required this.spec, required this.process});

  final RunnerSpec spec;
  final Process process;
}
