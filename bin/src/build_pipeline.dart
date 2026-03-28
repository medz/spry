import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/src/builder/target_spec.dart'
    show TargetSpec, buildTargetSpec;

import 'checks.dart';
import 'write.dart';

typedef ProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      Map<String, String>? environment,
      bool runInShell,
      Encoding? stdoutEncoding,
      Encoding? stderrEncoding,
    });

typedef BuildProgress = Future<void> Function(String label);

final class BuildResult {
  const BuildResult({
    required this.config,
    required this.tree,
    required this.targetCheck,
    required this.generatedFileCount,
    required this.routeCount,
    required this.middlewareCount,
    required this.generatedSourcePaths,
  });

  final BuildConfig config;
  final RouteTree tree;
  final TargetCheckResult targetCheck;
  final int generatedFileCount;
  final int routeCount;
  final int middlewareCount;

  /// Root-relative paths of files written directly into the source tree
  /// (i.e. rootRelative files outside outputDir, such as public/openapi.json).
  /// The watcher should ignore changes to these paths to avoid rebuild loops.
  final List<String> generatedSourcePaths;
}

Future<BuildResult> buildProject(
  BuildConfig config, {
  required StringSink out,
  required ProcessRunner processRunner,
  BuildProgress? progress,
}) async {
  await progress?.call('checking target setup...');
  final targetCheck = await checkTargetSetup(config, out);

  await progress?.call('scanning project tree...');
  final tree = await scan(config);

  await progress?.call('generating runtime files...');
  final files = await generate(tree, config);

  await progress?.call('writing generated output...');
  await writeGeneratedFiles(files, config);

  final generatedSourcePaths = files
      .where(
        (f) =>
            f.rootRelative &&
            !p.isWithin(config.outputDir, f.path) &&
            !p.equals(config.outputDir, f.path),
      )
      .map((f) => p.normalize(f.path))
      .toList();

  final spec = buildTargetSpec(config);
  final compiledRuntime =
      spec.compiledJsOutput != null || spec.dartCompileSubcommand != null;
  await progress?.call(
    compiledRuntime ? 'compiling runtime...' : 'finalizing build...',
  );
  await compileRuntime(config, processRunner: processRunner, spec: spec);
  return BuildResult(
    config: config,
    tree: tree,
    targetCheck: targetCheck,
    generatedFileCount: files.length,
    routeCount: tree.routes.length + (tree.fallback != null ? 1 : 0),
    middlewareCount:
        tree.globalMiddleware.length + tree.scopedMiddleware.length,
    generatedSourcePaths: generatedSourcePaths,
  );
}

Future<void> compileRuntime(
  BuildConfig config, {
  required ProcessRunner processRunner,
  TargetSpec? spec,
}) async {
  spec ??= buildTargetSpec(config);

  if (spec.compiledJsOutput case final jsOutput?) {
    await Directory(jsOutput).parent.create(recursive: true);
    final result = await processRunner(
      Platform.resolvedExecutable,
      [
        'compile',
        'js',
        p.join(config.outputDir, 'src', 'main.dart'),
        '-o',
        jsOutput,
      ],
      workingDirectory: config.rootDir,
      runInShell: Platform.isWindows,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw StateError((result.stderr as String).trim());
    }
    return;
  }

  if (spec.dartCompileSubcommand case final subcommand?) {
    final output = spec.dartCompileOutput!;
    await Directory(output).parent.create(recursive: true);
    final result = await processRunner(
      Platform.resolvedExecutable,
      [
        'compile',
        subcommand,
        p.join(config.outputDir, 'src', 'main.dart'),
        '-o',
        output,
      ],
      workingDirectory: config.rootDir,
      runInShell: Platform.isWindows,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw StateError((result.stderr as String).trim());
    }
  }
}
