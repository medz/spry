import 'dart:io';

import 'package:coal/args.dart';
import 'package:spry/builder.dart' show BuildConfig;
import 'package:spry/config.dart' show BuildTarget;

import 'ansi.dart';
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
  return runCommand(err, () async {
    final overrides = <String, Object>{};
    final output = stringArg(args, 'output');
    if (output != null) {
      overrides['outputDir'] = output;
    }

    final config = await loadCommandConfig(cwd, args, overrides: overrides);
    final spinner = Spinner.start(out, 'building ${config.target.name}...');
    final sw = Stopwatch()..start();
    final result = await buildProject(
      config,
      out: out,
      processRunner: processRunner,
    );
    sw.stop();
    final elapsed = (sw.elapsedMilliseconds / 1000).toStringAsFixed(1);
    spinner.done(
      '  ${green('✓')}  built ${bold(result.config.target.name)} → ${result.config.outputDir}  ${gray('(${elapsed}s)')}',
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
  });
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
