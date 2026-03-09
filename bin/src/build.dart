import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';

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

Future<int> runBuild(
  String cwd,
  Args args,
  StringSink out,
  StringSink err, {
  ProcessRunner processRunner = Process.run,
}
) async {
  try {
    final config = await loadConfig(
      configPath: _string(args, 'config'),
      overrides: {
        'rootDir': cwd,
        if (_string(args, 'output') case final value?) 'outputDir': value,
      },
    );
    await checkTargetSetup(config, out);
    final tree = await scan(config);
    final files = await generate(tree, config);
    await writeGeneratedFiles(files, config);
    await _compileRuntime(config, processRunner: processRunner);
    out.writeln('Generated ${files.length} file(s) into ${config.outputDir}');
    return 0;
  } catch (error) {
    err.writeln(error);
    return 1;
  }
}

String? _string(Args args, String key) => args[key]?.safeAs<String>();

Future<void> _compileRuntime(
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
      p.join(config.outputDir, 'main.js'),
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
