import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart' show BuildConfig;
import 'package:spry/config.dart' show BuildTarget;

import 'ansi.dart';
import 'build_client.dart';
import 'build_pipeline.dart';
import 'command_support.dart';
import 'spinner.dart';

Future<int> runBuild(
  String cwd,
  Args args,
  StringSink out,
  StringSink err, {
  ProcessRunner processRunner = Process.run,
}) async {
  switch (_buildSubcommand(args)) {
    case 'client':
      return runBuildClient(cwd, args, out, err);
    case null:
      break;
    case final command:
      err.writeln('Unknown build subcommand: $command');
      return 64;
  }

  return runCommand(err, () async {
    final overrides = <String, Object>{};
    final output = stringArg(args, 'output');
    if (output != null) {
      overrides['outputDir'] = output;
    }

    final config = await loadCommandConfig(cwd, args, overrides: overrides);
    final sw = Stopwatch()..start();
    final spinner = Spinner.start(out, 'building ${config.target.name}...');
    try {
      final result = await buildProject(
        config,
        out: out,
        processRunner: processRunner,
        progress: (label) async => spinner.update(label),
      );
      sw.stop();
      await spinner.done(
        '  ${green('✓')}  built ${bold(result.config.target.name)} → ${result.config.outputDir}  ${gray('(${_formatDuration(sw.elapsed)})')}',
      );

      out.writeln('');
      out.writeln(
        '  ${gray('routes')}  ${result.routeCount}   ${gray('middleware')}  ${result.middlewareCount}',
      );
      if (result.clientPkgDir case final clientPkgDir?) {
        out.writeln(
          '  ${gray('client')}  ${p.relative(clientPkgDir, from: result.config.rootDir)}',
        );
      }
      out.writeln('');
      out.writeln('  ${dim('next:')}');
      out.writeln('    ${cyan(_nextCommand(result.config))}');
      out.writeln('');
      out.writeln('  ${dim('docs:')}');
      out.writeln('    ${gray(_docsUrl(result.config.target))}');

      return 0;
    } catch (_) {
      await spinner.fail('  ${red('✗')}  build failed');
      rethrow;
    }
  });
}

String? _buildSubcommand(Args args) {
  final rest = args.rest;
  if (rest.isEmpty) {
    return null;
  }

  final buildRest = rest.first == 'build' ? rest.skip(1).toList() : rest;
  if (buildRest.isEmpty) {
    return null;
  }

  return buildRest.first;
}

String _formatDuration(Duration duration) {
  if (duration.inMilliseconds < 1000) {
    return '${duration.inMilliseconds}ms';
  }
  return '${(duration.inMilliseconds / 1000).toStringAsFixed(1)}s';
}

String _nextCommand(BuildConfig config) {
  final o = config.outputDir;
  return switch (config.target) {
    BuildTarget.vm => 'dart run ${p.join(o, 'src', 'main.dart')}',
    BuildTarget.exe => p.join(o, 'dart', 'server'),
    BuildTarget.aot => 'dartaotruntime ${p.join(o, 'dart', 'server.aot')}',
    BuildTarget.jit => 'dart run ${p.join(o, 'dart', 'server.jit')}',
    BuildTarget.kernel => 'dart run ${p.join(o, 'dart', 'server.dill')}',
    BuildTarget.node => 'node ${p.join(o, 'node', 'index.cjs')}',
    BuildTarget.bun => 'bun ${p.join(o, 'bun', 'index.js')}',
    BuildTarget.deno => 'deno run ${p.join(o, 'deno', 'index.js')}',
    BuildTarget.cloudflare => 'npx wrangler dev',
    BuildTarget.vercel => 'vercel dev',
    BuildTarget.netlify => 'netlify dev',
  };
}

String _docsUrl(BuildTarget target) {
  final slug = switch (target) {
    BuildTarget.vm ||
    BuildTarget.exe ||
    BuildTarget.aot ||
    BuildTarget.jit ||
    BuildTarget.kernel => 'dart',
    BuildTarget.node => 'node',
    BuildTarget.bun => 'bun',
    BuildTarget.deno => 'deno',
    BuildTarget.cloudflare => 'cloudflare',
    BuildTarget.vercel => 'vercel',
    BuildTarget.netlify => 'netlify',
  };
  return 'https://spry.medz.dev/deploy/$slug';
}
