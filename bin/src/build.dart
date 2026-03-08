import 'package:coal/args.dart';
import 'package:spry/builder.dart';

import 'write.dart';

Future<int> runBuild(
  String cwd,
  Args args,
  StringSink out,
  StringSink err,
) async {
  try {
    final config = await loadConfig(
      configPath: _string(args, 'config'),
      overrides: {
        'rootDir': cwd,
        if (_string(args, 'output') case final value?) 'outputDir': value,
      },
    );
    final tree = await scan(config);
    final files = await generate(tree, config);
    await writeGeneratedFiles(files, config);
    out.writeln('Generated ${files.length} file(s) into ${config.outputDir}');
    return 0;
  } catch (error) {
    err.writeln(error);
    return 1;
  }
}

String? _string(Args args, String key) => args[key]?.safeAs<String>();
