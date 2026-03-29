import 'dart:io';

import 'package:coal/args.dart';
import 'package:coal/utils.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart' show BuildConfig, generate, scan;
import 'package:spry/config.dart' show BuildTarget;
import 'package:spry/src/builder/client_generator.dart'
    show ensureClientPubspec, ensureSpryDependency, resolveClientPkgDir;
import 'package:spry/src/builder/target_spec.dart'
    show TargetSpec, buildTargetSpec;

import 'ansi.dart';
import 'build_client.dart';
import 'build_pipeline.dart' show ProcessRunner, compileRuntime;
import 'checks.dart';
import 'command_support.dart';
import 'progress.dart';
import 'write.dart';

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
    final rootDir = resolveCommandRoot(cwd, args);
    final reporter = CliProgressReporter.start(
      out,
      'Searching Spry config in $rootDir',
    );
    final totalSw = Stopwatch()..start();
    final overrides = <String, Object>{};
    final output = stringArg(args, 'output');
    if (output != null) {
      overrides['outputDir'] = output;
    }

    try {
      final configFile = displayPath(
        resolveCommandConfigFilePath(cwd, args),
        from: rootDir,
      );
      reporter.update('Loading Spry config from $configFile');
      final config = await loadCommandConfig(cwd, args, overrides: overrides);

      reporter.update('Checking target setup');
      await checkTargetSetup(config, out);

      final observed = observeScanEntries(
        scan(config),
        reporter: reporter,
        rootDir: config.rootDir,
      );

      String? clientPkgDir;
      if (config.client case final client?) {
        clientPkgDir = resolveClientPkgDir(config, client);
        reporter.update(
          'Preparing client package at ${displayPath(clientPkgDir, from: config.rootDir)}',
        );
        await ensureClientPubspec(clientPkgDir);
        reporter.update('Adding client dependencies');
        await ensureSpryDependency(clientPkgDir);
      }

      await writeGeneratedFiles(
        reportGeneratedEntries(
          generate(observed.entries, config),
          reporter,
          rootDir: config.rootDir,
        ),
        config,
      );
      final summary = await observed.summary;

      final spec = buildTargetSpec(config);
      if (spec.compiledJsOutput != null || spec.dartCompileSubcommand != null) {
        final targetOutput = spec.compiledJsOutput ?? spec.dartCompileOutput!;
        reporter.update(
          'Building target ${config.target.name} in ${displayPath(p.dirname(targetOutput), from: config.rootDir)}',
        );
        await compileRuntime(config, processRunner: processRunner, spec: spec);
      }

      totalSw.stop();
      await reporter.done();
      out.writeln('');
      out.writeln(
        '  ${gray('Generated runtime')}  ${styleText(displayPath(p.join(config.outputDir, 'src'), from: config.rootDir), [.underline])}',
      );
      if (_targetOutputPath(config, spec) case final targetPath?) {
        out.writeln(
          '  ${gray('Deploy Target (${config.target})')}  ${styleText(displayPath(targetPath, from: config.rootDir), [.underline])}',
        );
      }
      out.writeln(
        '  ${gray('Routes')}  ${summary.routeCount}   ${gray('Middleware')}  ${summary.middlewareCount}',
      );
      if (clientPkgDir != null) {
        out.writeln(
          '  ${gray('Client')}  ${styleText(p.relative(clientPkgDir, from: config.rootDir), [.underline])}',
        );
      }
      out.writeln('');
      out.writeln('  ${dim('Next:')}');
      out.writeln('    ${cyan(_nextCommand(config))}');
      out.writeln('');
      out.writeln('  ${dim('Docs:')}');
      out.writeln(
        '    ${styleText(_docsUrl(config.target), {.blue, .underline})}',
      );
      out.writeln('');
      out.writeln(
        '  🎉 Build completed successfully ${gray('(${formatProgressDuration(totalSw.elapsed)})')}',
      );
      out.writeln('');

      return 0;
    } catch (_) {
      await reporter.fail('Build failed');
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

String? _targetOutputPath(BuildConfig config, TargetSpec spec) {
  return switch (config.target) {
    BuildTarget.vm => null,
    BuildTarget.exe ||
    BuildTarget.aot ||
    BuildTarget.jit ||
    BuildTarget.kernel => spec.dartCompileOutput,
    BuildTarget.node => p.join(config.outputDir, 'node'),
    BuildTarget.bun => p.join(config.outputDir, 'bun'),
    BuildTarget.deno => p.join(config.outputDir, 'deno'),
    BuildTarget.cloudflare => p.join(config.outputDir, 'cloudflare'),
    BuildTarget.vercel => p.join(config.outputDir, 'vercel'),
    BuildTarget.netlify => p.join(config.outputDir, 'netlify'),
  };
}
