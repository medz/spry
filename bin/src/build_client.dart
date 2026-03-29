import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart'
    show
        BuildConfig,
        GeneratedEntry,
        GeneratedEntryType,
        RouteTree,
        collectRouteTree,
        generateEntriesFromTree,
        scanEntries;
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
  RouteTree? tree,
  CliProgressReporter? reporter,
}) async {
  final client = config.client ?? ClientConfig();
  tree ??= reporter == null
      ? await _scanClientTree(config)
      : await scanProjectTreeWithProgress(config, reporter);
  final pkgDir = resolveClientPkgDir(config, client);
  final outputDir = resolveClientOutputDir(pkgDir, client);

  reporter?.update(
    'Preparing client package at ${displayPath(pkgDir, from: config.rootDir)}',
  );
  await ensureClientPubspec(pkgDir);
  reporter?.update('Adding client dependencies');
  await ensureSpryDependency(pkgDir);
  final generatedFileCount = await _writeClientOutput(
    outputDir,
    (reporter == null
            ? generateEntriesFromTree(
                tree,
                config,
                includeRuntime: false,
                includeOpenApi: false,
                includeClient: true,
              )
            : reportGeneratedEntries(
                generateEntriesFromTree(
                  tree,
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

Future<RouteTree> _scanClientTree(BuildConfig config) {
  return collectRouteTree(scanEntries(config));
}

Future<int> _writeClientOutput(
  String outputDir,
  Stream<GeneratedEntry> entries,
  BuildConfig config,
) async {
  final routesDir = Directory(p.join(outputDir, 'routes'));
  if (await routesDir.exists()) {
    await routesDir.delete(recursive: true);
  }
  final paramsDir = Directory(p.join(outputDir, 'params'));
  if (await paramsDir.exists()) {
    await paramsDir.delete(recursive: true);
  }
  final inputsDir = Directory(p.join(outputDir, 'inputs'));
  if (await inputsDir.exists()) {
    await inputsDir.delete(recursive: true);
  }
  final modelsDir = Directory(p.join(outputDir, 'models'));
  if (await modelsDir.exists()) {
    await modelsDir.delete(recursive: true);
  }

  final routesLibrary = File(p.join(outputDir, 'routes.dart'));
  if (await routesLibrary.exists()) {
    await routesLibrary.delete();
  }
  final paramsLibrary = File(p.join(outputDir, 'params.dart'));
  if (await paramsLibrary.exists()) {
    await paramsLibrary.delete();
  }
  final inputsLibrary = File(p.join(outputDir, 'inputs.dart'));
  if (await inputsLibrary.exists()) {
    await inputsLibrary.delete();
  }
  final modelsLibrary = File(p.join(outputDir, 'models.dart'));
  if (await modelsLibrary.exists()) {
    await modelsLibrary.delete();
  }

  final result = await writeGeneratedEntries(
    entries,
    config,
    recreateOutputDir: false,
    syncPublicDir: false,
  );
  return result.generatedFileCount;
}
