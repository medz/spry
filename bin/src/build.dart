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
    final overrides = <String, Object>{};
    final output = stringArg(args, 'output');
    if (output != null) {
      overrides['outputDir'] = output;
    }

    final config = await loadCommandConfig(
      cwd,
      args,
      overrides: overrides,
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
