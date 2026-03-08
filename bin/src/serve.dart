import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';
import 'package:watcher/watcher.dart';

import 'tools/bun.dart';
import 'write.dart';

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
        processRunner: processRunner,
        installBun: installBun,
      );
      if (nextBuild == null) {
        continue;
      }

      final canHotSwap =
          nextConfig.reload == ReloadStrategy.hotswap &&
          _supportsHotSwap(nextConfig.target) &&
          _sameRunnerSpec(session.spec, nextBuild.spec);

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
  final build = await _build(
    config,
    processRunner: processRunner,
    installBun: installBun,
  );
  out.writeln('Serving ${config.target.name} from ${config.outputDir}');
  return _startRunner(build.spec, processStarter: processStarter);
}

Future<_BuiltServeState?> _tryBuild(
  BuildConfig config, {
  required StringSink err,
  required ProcessRunner processRunner,
  required BunInstaller? installBun,
}) async {
  try {
    return await _build(
      config,
      processRunner: processRunner,
      installBun: installBun,
    );
  } catch (error) {
    err.writeln(error);
    return null;
  }
}

Future<_BuiltServeState> _build(
  BuildConfig config, {
  required ProcessRunner processRunner,
  required BunInstaller? installBun,
}) async {
  final tree = await scan(config);
  final files = await generate(tree, config);
  await writeGeneratedFiles(files, config);

  final outputMain = p.join(config.outputDir, 'main.dart');
  switch (config.target) {
    case BuildTarget.dart:
      return _BuiltServeState(
        spec: _RunnerSpec(
          executable: Platform.resolvedExecutable,
          arguments: ['run', outputMain],
          workingDirectory: config.rootDir,
        ),
      );
    case BuildTarget.node:
    case BuildTarget.bun:
    case BuildTarget.cloudflare:
    case BuildTarget.vercel:
      final compile = await processRunner(
        Platform.resolvedExecutable,
        [
          'compile',
          'js',
          outputMain,
          '-o',
          p.join(config.outputDir, 'main.js'),
        ],
        workingDirectory: config.rootDir,
        runInShell: Platform.isWindows,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      if (compile.exitCode != 0) {
        throw StateError((compile.stderr as String).trim());
      }

      final bun = await resolveBunExecutable(
        config.rootDir,
        processRunner: processRunner,
        installBun: installBun,
      );
      final outputDir = p.join(config.rootDir, config.outputDir);
      if (config.target == BuildTarget.vercel) {
        final install = await processRunner(
          bun,
          ['install'],
          workingDirectory: outputDir,
          runInShell: Platform.isWindows,
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );
        if (install.exitCode != 0) {
          throw StateError((install.stderr as String).trim());
        }
      }
      return _BuiltServeState(
        spec: switch (config.target) {
          BuildTarget.node || BuildTarget.bun => _RunnerSpec(
            executable: bun,
            arguments: [p.join(config.outputDir, 'main.js')],
            workingDirectory: config.rootDir,
          ),
          BuildTarget.cloudflare => _RunnerSpec(
            executable: bun,
            arguments: [
              'x',
              'wrangler',
              'dev',
              '_worker.mjs',
              '--ip',
              config.host,
              '--port',
              '${config.port}',
            ],
            workingDirectory: outputDir,
          ),
          BuildTarget.vercel => _RunnerSpec(
            executable: bun,
            arguments: [
              'x',
              'vercel',
              'dev',
              '--local',
              '--yes',
              '--listen',
              '${config.host}:${config.port}',
            ],
            workingDirectory: outputDir,
          ),
          BuildTarget.dart => throw StateError('unreachable'),
        },
      );
  }
}

Future<_ServeSession> _startRunner(
  _RunnerSpec spec, {
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
  final configFile = (configPath ?? 'spry.config.dart').replaceAll('\\', '/');

  if (_isUnder(normalized, outputDir) ||
      _isUnder(normalized, '.dart_tool') ||
      _isUnder(normalized, '.git')) {
    return false;
  }

  return normalized == 'hooks.dart' ||
      normalized == configFile ||
      _isUnder(normalized, routesDir) ||
      _isUnder(normalized, middlewareDir);
}

bool _isUnder(String path, String prefix) {
  return path == prefix || path.startsWith('$prefix/');
}

bool _supportsHotSwap(BuildTarget target) {
  return switch (target) {
    BuildTarget.cloudflare || BuildTarget.vercel => true,
    _ => false,
  };
}

bool _sameRunnerSpec(_RunnerSpec a, _RunnerSpec b) {
  if (a.executable != b.executable ||
      a.workingDirectory != b.workingDirectory) {
    return false;
  }
  if (a.arguments.length != b.arguments.length) {
    return false;
  }
  for (var i = 0; i < a.arguments.length; i++) {
    if (a.arguments[i] != b.arguments[i]) {
      return false;
    }
  }
  return true;
}

String? _string(Args args, String key) => args[key]?.safeAs<String>();

final class _BuiltServeState {
  const _BuiltServeState({required this.spec});

  final _RunnerSpec spec;
}

final class _RunnerSpec {
  const _RunnerSpec({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
  });

  final String executable;
  final List<String> arguments;
  final String workingDirectory;
}

final class _ServeSession {
  const _ServeSession({required this.spec, required this.process});

  final _RunnerSpec spec;
  final Process process;
}
