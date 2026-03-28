import 'dart:async';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:spry/builder.dart' show BuildConfig;
import 'package:spry/config.dart';

import 'ansi.dart';
import 'build_pipeline.dart';
import 'command_support.dart';
import 'runtime_runner.dart';
import 'spinner.dart';
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

typedef _BuildPlan = ({BuildResult build, ServePlan plan});

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
    var generatedSourcePaths = <String>{};
    final events =
        watchEvents ??
        watchServeInputs(
          config.rootDir,
          currentConfig: () => config,
          configPath: configPath,
          generatedSourcePaths: () => generatedSourcePaths,
        );
    final changes = StreamIterator(events);

    final firstBuild = await _buildAndStart(
      config,
      out: out,
      err: err,
      processRunner: processRunner,
      processStarter: processStarter,
      installBun: installBun,
    );
    generatedSourcePaths = firstBuild.plan.build.generatedSourcePaths.toSet();
    var session = firstBuild.session;

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
      out.writeln('  ${bold(changed)} changed');

      BuildConfig nextConfig;
      try {
        nextConfig = await readConfig();
      } catch (error) {
        err.writeln('');
        err.writeln('  ${red('✗')}  config error');
        err.writeln('     $error');
        out.writeln('');
        out.writeln('  ${gray('watching for file changes...')}');
        continue;
      }

      final spinner = Spinner.start(out, 'rebuilding...');
      final sw = Stopwatch()..start();
      final nextBuildPlan = await _tryBuild(
        nextConfig,
        err: err,
        out: out,
        processRunner: processRunner,
        installBun: installBun,
        spinner: spinner,
      );
      sw.stop();

      if (nextBuildPlan == null) {
        out.writeln('');
        out.writeln('  ${gray('watching for file changes...')}');
        continue;
      }

      final canHotSwap =
          nextConfig.reload == ReloadStrategy.hotswap &&
          nextBuildPlan.plan.supportsHotSwap &&
          sameRunnerSpec(session.spec, nextBuildPlan.plan.spec);

      config = nextConfig;
      generatedSourcePaths = nextBuildPlan.build.generatedSourcePaths.toSet();
      if (canHotSwap) {
        await spinner.done(
          '  ${green('↻')}  rebuilt in ${sw.elapsedMilliseconds}ms',
        );
        await _printReadyBlock(config, out, build: nextBuildPlan.build);
        continue;
      }

      session.process.kill();
      await session.process.exitCode;
      session = await _startRunner(
        nextBuildPlan.plan.spec,
        processStarter: processStarter,
      );
      await spinner.done(
        '  ${green('↺')}  restarted in ${sw.elapsedMilliseconds}ms',
      );
      await _printReadyBlock(config, out, build: nextBuildPlan.build);
    }
  });
}

Future<({_BuildPlan plan, _ServeSession session})> _buildAndStart(
  BuildConfig config, {
  required StringSink out,
  required StringSink err,
  required ProcessRunner processRunner,
  required ProcessStarter processStarter,
  required BunInstaller? installBun,
}) async {
  final spinner = Spinner.start(out, 'building ${config.target.name}...');
  final bp = await _prepareServeBuild(
    config,
    out: out,
    processRunner: processRunner,
    installBun: installBun,
    progress: (label) async => spinner.update(label),
  );
  await spinner.done(
    '  ${green('✓')}  built ${bold(config.target.name)} → ${config.outputDir}',
  );
  await _printReadyBlock(config, out, build: bp.build);
  final session = await _startRunner(
    bp.plan.spec,
    processStarter: processStarter,
  );
  return (plan: bp, session: session);
}

Future<_BuildPlan?> _tryBuild(
  BuildConfig config, {
  required StringSink err,
  required StringSink out,
  required ProcessRunner processRunner,
  required BunInstaller? installBun,
  required Spinner spinner,
}) async {
  try {
    return await _prepareServeBuild(
      config,
      out: out,
      processRunner: processRunner,
      installBun: installBun,
      progress: (label) async => spinner.update(label),
    );
  } catch (error) {
    await spinner.fail('  ${red('✗')}  build failed');
    for (final line in error.toString().split('\n')) {
      err.writeln('     $line');
    }
    return null;
  }
}

Future<void> _printReadyBlock(
  BuildConfig config,
  StringSink out, {
  required BuildResult build,
}) async {
  final host = config.host == '0.0.0.0' ? 'localhost' : config.host;
  final lanIp = config.host == '0.0.0.0' ? await _getLanIp() : null;

  out.writeln('');
  out.writeln(
    '  ${gray('routes')}  ${build.routeCount}   ${gray('middleware')}  ${build.middlewareCount}',
  );
  out.writeln('');
  if (lanIp != null) {
    out.writeln(
      '  ${cyan('➜')}  Local:    ${cyan('http://$host:${config.port}/')}',
    );
    out.writeln(
      '  ${gray('➜')}  Network:  ${gray('http://$lanIp:${config.port}/')}',
    );
  } else {
    out.writeln('  ${cyan('➜')}  ${cyan('http://$host:${config.port}/')}');
  }
  final uiRoute = config.openapi?.ui?.route;
  if (uiRoute != null) {
    out.writeln(
      '  ${gray('➜')}  API docs: ${gray('http://$host:${config.port}$uiRoute')}',
    );
  }
  out.writeln('');
  out.writeln('  ${gray('watching for file changes...')}');
}

Future<String?> _getLanIp() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
  } catch (_) {}
  return null;
}

Future<_BuildPlan> _prepareServeBuild(
  BuildConfig config, {
  required StringSink out,
  required ProcessRunner processRunner,
  required BunInstaller? installBun,
  BuildProgress? progress,
}) async {
  final build = await buildProject(
    config,
    out: out,
    processRunner: processRunner,
    progress: progress,
  );
  final plan = await createServePlan(
    build,
    processRunner: processRunner,
    installBun: installBun,
  );
  return (build: build, plan: plan);
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
