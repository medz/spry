import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:spry/builder.dart' show BuildConfig;
import 'package:spry/config.dart';
import 'package:spry/osrv.dart';
import 'package:spry/osrv/dart.dart' show serve;
import 'package:spry/spry.dart';
import 'package:spry/src/builder/scanner.dart';
import 'package:spry/src/mcp/mcp_protocol.dart';
import 'package:spry/src/mcp/mcp_server.dart' as mcp_server;
import 'package:spry/src/mcp/mcp_tools.dart' show ProjectState;

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

      await session.close();
      final nextBuildSession = await _buildAndStart(
        config,
        out: out,
        err: err,
        processRunner: processRunner,
        processStarter: processStarter,
        installBun: installBun,
      );
      session = nextBuildSession.session;
      await spinner.done(
        '  ${green('↺')}  restarted in ${sw.elapsedMilliseconds}ms',
      );
      await _printReadyBlock(config, out, build: nextBuildPlan.build);
    }
  });
}

Future<_BuildAndStartResult> _buildAndStart(
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
  );
  await spinner.done(
    '  ${green('✓')}  built ${bold(config.target.name)} → ${config.outputDir}',
  );
  await _printReadyBlock(config, out, build: bp.build);

  // Start the main app runner.
  final session = await _startRunner(
    bp.plan.spec,
    processStarter: processStarter,
  );

  // Start MCP Spry instance alongside when enabled.
  if (config.mcp?.enable == true) {
    await _startMcpInstance(config, out, session);
  }

  return (plan: bp, session: session);
}

/// Starts a Spry-based MCP server in the same process, bound to a local port.
Future<void> _startMcpInstance(
  BuildConfig config,
  StringSink out,
  _ServeSession session,
) async {
  final mcpPort = config.mcp!.effectivePort(config.port);
  final entries = await scan(config).toList();
  final state = ProjectState(config: config, entries: entries);

  final mcpApp = Spry(
    routes: {
      '/': {
        null: (Event event) async {
          if (event.request.method != HttpMethod.post) {
            final error = JsonRpcError.methodNotFound(
              null,
              event.request.method.value,
            );
            return Response(
              jsonEncode(error.toJson()),
              ResponseInit(
                status: 405,
                headers: {'content-type': 'application/json'},
              ),
            );
          }
          return _handleMcpEvent(event, state);
        },
      },
    },
  );

  final host = config.host == '0.0.0.0'
      ? InternetAddress.loopbackIPv4.address
      : config.host;
  final server = Server(fetch: mcpApp.fetch);
  final runtime = await serve(server, host: host, port: mcpPort);
  session.mcpRuntime = runtime;

  out.writeln(
    '  ${gray('➜')}  MCP:      ${gray('http://${config.host == '0.0.0.0' ? 'localhost' : config.host}:$mcpPort/')}',
  );
}

/// Handles an MCP JSON-RPC request through a Spry Event.
Future<Response> _handleMcpEvent(Event event, ProjectState state) async {
  final body = await event.request.text();
  if (body.isEmpty) {
    return _mcpResponse(
      JsonRpcError.internalError(null, 'Empty body').toJson(),
    );
  }

  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return _mcpResponse(
        JsonRpcError.internalError(null, 'Expected JSON object').toJson(),
      );
    }

    final rpcRequest = JsonRpcRequest.fromJson(decoded);
    if (rpcRequest.id == null) {
      mcp_server.handleNotification(rpcRequest, state);
      return Response(null, ResponseInit(status: 202));
    }

    final result = mcp_server.dispatch(rpcRequest, state);
    return _mcpResponse(result.toJson());
  } on FormatException catch (e) {
    return _mcpResponse(JsonRpcError.parseError(message: e.message).toJson());
  } on ArgumentError catch (e) {
    return _mcpResponse(JsonRpcError.internalError(null, e.message).toJson());
  }
}

Response _mcpResponse(Map<String, dynamic> body) {
  return Response(
    jsonEncode(body),
    ResponseInit(status: 200, headers: {'content-type': 'application/json'}),
  );
}

typedef _BuildAndStartResult = ({_BuildPlan plan, _ServeSession session});

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
  final openapi = config.openapi;
  if (openapi != null && openapi.ui != null && openapi.output.type == 'route') {
    out.writeln(
      '  ${gray('➜')}  OpenAPI:  ${gray('http://$host:${config.port}${openapi.ui!.route}')}',
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
}) async {
  final build = await buildProject(
    config,
    out: out,
    processRunner: processRunner,
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
  _ServeSession({required this.spec, required this.process});

  final RunnerSpec spec;
  final Process process;

  /// MCP Spry runtime for cleanup on restart.
  Runtime? mcpRuntime;

  Future<void> close() async {
    process.kill();
    await process.exitCode;
    await mcpRuntime?.close();
  }
}

bool sameRunnerSpec(RunnerSpec a, RunnerSpec b) {
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
