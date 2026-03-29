import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart'
    show BuildConfig, GeneratedEntry, GeneratedEntryType, RouteTree;
import 'package:spry/config.dart' show ClientConfig;
import 'package:spry/src/builder/client_generator.dart'
    show
        ensureClientPubspec,
        ensureSpryDependency,
        resolveClientOutputDir,
        resolveClientPkgDir;
import 'package:spry/src/builder/generator.dart' show generateEntriesFromTree;

import 'ansi.dart';
import 'build_pipeline.dart' show BuildProgress, scanProjectTree;
import 'command_support.dart';
import 'spinner.dart';

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
    final config = await loadCommandConfig(cwd, args);
    final spinner = Spinner.start(out, 'building client...');
    try {
      final result = await buildClientProject(
        config,
        progress: (label) async => spinner.update(label),
      );
      await spinner.done(
        '  ${green('✓')}  built client → ${p.relative(result.pkgDir, from: config.rootDir)}',
      );
      return 0;
    } catch (_) {
      await spinner.fail('  ${red('✗')}  client build failed');
      rethrow;
    }
  });
}

Future<ClientBuildResult> buildClientProject(
  BuildConfig config, {
  RouteTree? tree,
  BuildProgress? progress,
}) async {
  final client = config.client ?? ClientConfig();
  tree ??= await scanProjectTree(config, progress: progress);
  final pkgDir = resolveClientPkgDir(config, client);
  final outputDir = resolveClientOutputDir(pkgDir, client);

  await progress?.call('preparing client package...');
  await ensureClientPubspec(pkgDir);
  await progress?.call('syncing spry dependency...');
  await ensureSpryDependency(pkgDir);
  await progress?.call('generating client files...');
  final generatedFileCount = await _writeClientOutput(
    outputDir,
    config.rootDir,
    generateEntriesFromTree(
      tree,
      config,
    ).where((entry) => entry.type == GeneratedEntryType.clientSource),
  );
  return ClientBuildResult(
    pkgDir: pkgDir,
    outputDir: outputDir,
    generatedFileCount: generatedFileCount,
  );
}

Future<int> _writeClientOutput(
  String outputDir,
  String rootDir,
  Stream<GeneratedEntry> entries,
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

  var generatedFileCount = 0;
  await for (final entry in entries) {
    final file = File(p.normalize(p.absolute(rootDir, entry.path)));
    await file.parent.create(recursive: true);
    await file.writeAsString(entry.content);
    generatedFileCount++;
  }
  return generatedFileCount;
}
