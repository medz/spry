import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/src/builder/client_generator.dart'
    show ensureClientPubspec, ensureSpryDependency, resolveClientPkgDir;
import 'package:spry/src/builder/target_spec.dart'
    show TargetSpec, buildTargetSpec;

import 'checks.dart';
import 'progress.dart';
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

final class BuildResult {
  const BuildResult({
    required this.config,
    required this.targetCheck,
    required this.generatedFileCount,
    required this.routeCount,
    required this.middlewareCount,
    required this.generatedSourcePaths,
    required this.generatedClientFileCount,
    this.clientPkgDir,
  });

  final BuildConfig config;
  final TargetCheckResult targetCheck;
  final int generatedFileCount;
  final int routeCount;
  final int middlewareCount;
  final int generatedClientFileCount;
  final String? clientPkgDir;

  /// Root-relative paths of files written directly into the source tree
  /// (i.e. rootRelative files outside outputDir, such as public/openapi.json).
  /// The watcher should ignore changes to these paths to avoid rebuild loops.
  final List<String> generatedSourcePaths;
}

Future<BuildResult> buildProject(
  BuildConfig config, {
  required StringSink out,
  required ProcessRunner processRunner,
}) async {
  final targetCheck = await checkTargetSetup(config, out);
  final observed = observeScanEntries(scan(config));

  String? clientPkgDir;
  if (config.client case final client?) {
    clientPkgDir = resolveClientPkgDir(config, client);
    await ensureClientPubspec(clientPkgDir);
    await ensureSpryDependency(clientPkgDir);
  }

  final writeResult = await writeGeneratedFiles(
    generate(observed.entries, config),
    config,
  );
  final summary = await observed.summary;

  final spec = buildTargetSpec(config);
  await compileRuntime(config, processRunner: processRunner, spec: spec);
  return BuildResult(
    config: config,
    targetCheck: targetCheck,
    generatedFileCount: writeResult.generatedFileCount,
    routeCount: summary.routeCount,
    middlewareCount: summary.middlewareCount,
    generatedSourcePaths: writeResult.generatedSourcePaths,
    generatedClientFileCount: writeResult.generatedClientFileCount,
    clientPkgDir: clientPkgDir,
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
