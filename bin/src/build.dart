import 'dart:io';

import 'package:coal/args.dart';

import 'build_pipeline.dart';
import 'command_support.dart';

Future<int> runBuild(
  String cwd,
  Args args,
  StringSink out,
  StringSink err, {
  ProcessRunner processRunner = Process.run,
}) async {
  return runCommand(err, () async {
    final config = await loadCommandConfig(
      cwd,
      args,
      overrides: {
        if (stringArg(args, 'output') case final value?) 'outputDir': value,
      },
    );
    final result = await buildProject(
      config,
      out: out,
      processRunner: processRunner,
    );
    out.writeln(
      'Generated ${result.generatedFileCount} file(s) into ${config.outputDir}',
    );
    return 0;
  });
}
