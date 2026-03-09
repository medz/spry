import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:spry/builder.dart' show loadConfig;

import 'build_pipeline.dart';

Future<int> runBuild(
  String cwd,
  Args args,
  StringSink out,
  StringSink err, {
  ProcessRunner processRunner = Process.run,
}) async {
  try {
    final config = await loadConfig(
      configPath: _string(args, 'config'),
      overrides: {
        'rootDir': cwd,
        if (_string(args, 'output') case final value?) 'outputDir': value,
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
  } catch (error) {
    err.writeln(error);
    return 1;
  }
}

String? _string(Args args, String key) => args[key]?.safeAs<String>();
