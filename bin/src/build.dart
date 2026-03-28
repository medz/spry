import 'dart:io';

import 'package:coal/args.dart';
import 'package:spry/builder.dart' show BuildConfig;
import 'package:spry/config.dart' show BuildTarget;

import 'ansi.dart';
import 'build_pipeline.dart';
import 'command_support.dart';
import 'spinner.dart';

typedef CommandConfigLoader =
    Future<BuildConfig> Function(
      String cwd,
      Args args, {
      Map<String, dynamic> overrides,
    });

typedef BuildRunner =
    Future<BuildResult> Function(
      BuildConfig config, {
      required StringSink out,
      required ProcessRunner processRunner,
      BuildProgress? progress,
    });

final class _BuildProgressReporter {
  _BuildProgressReporter(this._out);

  final StringSink _out;
  Spinner? _spinner;
  Stopwatch? _stopwatch;
  String? _label;

  Future<void> start(String label) async {
    await complete();
    _label = label;
    _stopwatch = Stopwatch()..start();
    _spinner = Spinner.start(_out, label);
  }

  Future<void> complete([String? completedLabel]) async {
    final spinner = _spinner;
    final stopwatch = _stopwatch;
    final label = _label;
    if (spinner == null || stopwatch == null || label == null) {
      return;
    }

    stopwatch.stop();
    await spinner.done(
      '  ${green('✓')}  ${completedLabel ?? _completedLabel(label)}  ${gray('(${_formatDuration(stopwatch.elapsed)})')}',
    );
    _spinner = null;
    _stopwatch = null;
    _label = null;
  }

  Future<void> fail(String line) async {
    final spinner = _spinner;
    if (spinner == null) {
      return;
    }
    await spinner.fail(line);
    _spinner = null;
    _stopwatch = null;
    _label = null;
  }

  static String _completedLabel(String label) {
    return switch (label) {
      'loading config...' => 'loaded config',
      'checking target setup...' => 'checked target setup',
      'scanning project tree...' => 'scanned project tree',
      'generating runtime files...' => 'generated runtime files',
      'writing generated output...' => 'wrote generated output',
      'compiling runtime...' => 'compiled runtime',
      'finalizing build...' => 'finalized build',
      _ => label.replaceAll(RegExp(r'\.\.\.$'), ''),
    };
  }
}

Future<int> runBuild(
  String cwd,
  Args args,
  StringSink out,
  StringSink err, {
  ProcessRunner processRunner = Process.run,
  CommandConfigLoader commandConfigLoader = loadCommandConfig,
  BuildRunner buildRunner = buildProject,
}) async {
  return runCommand(err, () async {
    final overrides = <String, Object>{};
    final output = stringArg(args, 'output');
    if (output != null) {
      overrides['outputDir'] = output;
    }

    final progress = _BuildProgressReporter(out);
    try {
      await progress.start('loading config...');
      final configSw = Stopwatch()..start();
      final config = await commandConfigLoader(cwd, args, overrides: overrides);
      configSw.stop();
      await progress.complete('loaded config for ${config.target.name}');

      final result = await buildRunner(
        config,
        out: out,
        processRunner: processRunner,
        progress: progress.start,
      );
      await progress.complete();
      out.writeln(
        '  ${green('✓')}  built ${bold(result.config.target.name)} → ${result.config.outputDir}',
      );

      out.writeln('');
      out.writeln(
        '  ${gray('routes')}  ${result.routeCount}   ${gray('middleware')}  ${result.middlewareCount}',
      );
      out.writeln('');
      out.writeln('  ${dim('next:')}');
      out.writeln('    ${cyan(_nextCommand(result.config))}');
      out.writeln('');
      out.writeln('  ${dim('docs:')}');
      out.writeln('    ${gray(_docsUrl(result.config.target))}');

      return 0;
    } catch (_) {
      await progress.fail('  ${red('✗')}  build failed');
      rethrow;
    }
  });
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
    BuildTarget.vm => 'dart run $o/src/main.dart',
    BuildTarget.exe => './$o/dart/server',
    BuildTarget.aot => 'dartaotruntime $o/dart/server.aot',
    BuildTarget.jit => 'dart run $o/dart/server.jit',
    BuildTarget.kernel => 'dart run $o/dart/server.dill',
    BuildTarget.node => 'node $o/node/index.cjs',
    BuildTarget.bun => 'bun $o/bun/index.js',
    BuildTarget.deno => 'deno run $o/deno/index.js',
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
