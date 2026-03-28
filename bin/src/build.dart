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

    final config = await loadCommandConfig(cwd, args, overrides: overrides);
    final sw = Stopwatch()..start();
    final result = await buildProject(
      config,
      out: out,
      processRunner: processRunner,
    );
    sw.stop();
    final elapsed = (sw.elapsedMilliseconds / 1000).toStringAsFixed(1);
    out.writeln(
      '  ✓  built ${result.config.target.name} → ${config.outputDir}  (${elapsed}s)',
    );
    return 0;
  });
}
