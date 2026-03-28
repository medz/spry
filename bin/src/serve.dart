import 'dart:async';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:spry/builder.dart' show BuildConfig;
import 'package:spry/config.dart';

import 'build_pipeline.dart';
import 'command_support.dart';
import 'runtime_runner.dart';
import 'tools/bun.dart';
import 'watch_support.dart';

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
  Stream<String>? watchEvents,
}) async {
  final configPath = stringArg(args, 'config');

  return runCommand(err, () async {
    Future<BuildConfig> readConfig() => loadCommandConfig(cwd, args);

    var config = await readConfig();
    final events =
        watchEvents ??
        watchServeInputs(
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

      final changed = changes.current;
      out.writeln('');
      out.writeln('  $changed changed');

      BuildConfig nextConfig;
      try {
        nextConfig = await readConfig();
      } catch (error) {
        err.writeln('');
        err.writeln('  ✗  config error');
        err.writeln('     $error');
        out.writeln('');
        out.writeln('  watching for file changes...');
        continue;
      }

      final sw = Stopwatch()..start();
      final nextBuild = await _tryBuild(
        nextConfig,
        err: err,
        out: out,
        processRunner: processRunner,
        installBun: installBun,
      );
      sw.stop();

      if (nextBuild == null) {
        out.writeln('');
        out.writeln('  watching for file changes...');
        continue;
      }

      final canHotSwap =
          nextConfig.reload == ReloadStrategy.hotswap &&
          nextBuild.supportsHotSwap &&
          sameRunnerSpec(session.spec, nextBuild.spec);

      config = nextConfig;
      if (canHotSwap) {
        out.writeln('');
        out.writeln('  ↻  rebuilt in ${sw.elapsedMilliseconds}ms');
        _printReadyBlock(config, out);
        continue;
      }

      session.process.kill();
      await session.process.exitCode;
      session = await _startRunner(
        nextBuild.spec,
        processStarter: processStarter,
      );
      out.writeln('');
      out.writeln('  ↺  restarted in ${sw.elapsedMilliseconds}ms');
      _printReadyBlock(config, out);
    }
  });
}

Future<_ServeSession> _buildAndStart(
  BuildConfig config, {
  required StringSink out,
  required StringSink err,
  required ProcessRunner processRunner,
  required ProcessStarter processStarter,
  required BunInstaller? installBun,
}) async {
  out.writeln('  building...');
  final build = await _prepareServeBuild(
    config,
    out: out,
    processRunner: processRunner,
    installBun: installBun,
  );
  _printReadyBlock(config, out);
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
    err.writeln('');
    err.writeln('  ✗  build failed');
    for (final line in error.toString().split('\n')) {
      err.writeln('     $line');
    }
    return null;
  }
}

void _printReadyBlock(BuildConfig config, StringSink out) {
  final host = config.host == '0.0.0.0' ? 'localhost' : config.host;
  out.writeln('');
  out.writeln('  ➜  http://$host:${config.port}/');
  out.writeln('');
  out.writeln('  watching for file changes...');
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

final class _ServeSession {
  const _ServeSession({required this.spec, required this.process});

  final RunnerSpec spec;
  final Process process;
}
