import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';
import 'package:spry/src/builder/target_spec.dart';

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

final class BuildResult {
  const BuildResult({
    required this.config,
    required this.targetCheck,
    required this.generatedFileCount,
  });

  final BuildConfig config;
  final TargetCheckResult targetCheck;
  final int generatedFileCount;
}

Future<BuildResult> buildProject(
  BuildConfig config, {
  required StringSink out,
  required ProcessRunner processRunner,
}) async {
  final targetCheck = await checkTargetSetup(config, out);
  final tree = await scan(config);
  final files = await generate(tree, config);
  await writeGeneratedFiles(files, config);
  await compileRuntime(config, processRunner: processRunner);
  return BuildResult(
    config: config,
    targetCheck: targetCheck,
    generatedFileCount: files.length,
  );
}

Future<void> compileRuntime(
  BuildConfig config, {
  required ProcessRunner processRunner,
}) async {
  if (config.target == BuildTarget.dart) {
    return;
  }

  final result = await processRunner(
    Platform.resolvedExecutable,
    [
      'compile',
      'js',
      p.join(config.outputDir, 'main.dart'),
      '-o',
      compiledJsOutput(config),
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
