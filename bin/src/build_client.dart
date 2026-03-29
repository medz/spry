import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart'
    show BuildConfig, GeneratedEntry, GeneratedEntryType, generate, scan;
import 'package:spry/config.dart' show ClientConfig;
import 'package:spry/src/builder/client_generator.dart'
    show
        ensureClientPubspec,
        ensureSpryDependency,
        resolveClientOutputDir,
        resolveClientPkgDir;

import 'ansi.dart';
import 'command_support.dart';
import 'progress.dart';
import 'write.dart';

final class ClientBuildResult {
  const ClientBuildResult({
    required this.pkgDir,
    required this.outputDir,
    required this.generatedFileCount,
  });

  final String pkgDir;
  final String outputDir;
  final int generatedFileCount;
}

Future<int> runBuildClient(
  String cwd,
  Args args,
  StringSink out,
  StringSink err,
) async {
  return runCommand(err, () async {
    final rootDir = resolveCommandRoot(cwd, args);
    final reporter = CliProgressReporter.start(
      out,
      'Searching Spry config in $rootDir',
    );
    final totalSw = Stopwatch()..start();
    try {
      final configFile = displayPath(
        resolveCommandConfigFilePath(cwd, args),
        from: rootDir,
      );
      reporter.update('Loading Spry config from $configFile');
      final config = await loadCommandConfig(cwd, args);
      final result = await buildClientProject(config, reporter: reporter);
      totalSw.stop();
      await reporter.done();
      out.writeln(
        '  ${gray('client')}  ${p.relative(result.pkgDir, from: config.rootDir)}',
      );
      out.writeln('');
      out.writeln(
        '  ${green('✓')}  🎉 Build completed successfully (${formatProgressDuration(totalSw.elapsed)})',
      );
      return 0;
    } catch (_) {
      await reporter.fail('Client build failed');
      rethrow;
    }
  });
}

Future<ClientBuildResult> buildClientProject(
  BuildConfig config, {
  CliProgressReporter? reporter,
}) async {
  final client = config.client ?? ClientConfig();
  final pkgDir = resolveClientPkgDir(config, client);
  final outputDir = resolveClientOutputDir(pkgDir, client);

  reporter?.update(
    'Preparing client package at ${displayPath(pkgDir, from: config.rootDir)}',
  );
  await ensureClientPubspec(pkgDir);
  reporter?.update('Adding client dependencies');
  await ensureSpryDependency(pkgDir);
  final observed = observeScanEntries(
    scan(config),
    reporter: reporter,
    rootDir: reporter == null ? null : config.rootDir,
  );
  final generatedFileCount = await _writeClientOutput(
    outputDir,
    (reporter == null
            ? generate(
                observed.entries,
                config,
                includeRuntime: false,
                includeOpenApi: false,
                includeClient: true,
              )
            : reportGeneratedEntries(
                generate(
                  observed.entries,
                  config,
                  includeRuntime: false,
                  includeOpenApi: false,
                  includeClient: true,
                ),
                reporter,
                rootDir: config.rootDir,
              ))
        .where((entry) => entry.type == GeneratedEntryType.clientSource),
    config,
  );
  return ClientBuildResult(
    pkgDir: pkgDir,
    outputDir: outputDir,
    generatedFileCount: generatedFileCount,
  );
}

Future<int> _writeClientOutput(
  String outputDir,
  Stream<GeneratedEntry> entries,
  BuildConfig config,
) async {
  const subdirs = [
    'routes',
    'params',
    'inputs',
    'headers',
    'queries',
    'outputs',
    'models',
  ];
  for (final name in subdirs) {
    final dir = Directory(p.join(outputDir, name));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  const barrelFiles = [
    'routes.dart',
    'params.dart',
    'inputs.dart',
    'headers.dart',
    'queries.dart',
    'outputs.dart',
    'models.dart',
  ];
  for (final name in barrelFiles) {
    final file = File(p.join(outputDir, name));
    if (await file.exists()) {
      await file.delete();
    }
  }

  final result = await writeGeneratedFiles(
    entries,
    config,
    recreateOutputDir: false,
    syncPublicDir: false,
  );
  return result.generatedFileCount;
}
