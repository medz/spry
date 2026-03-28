import 'package:coal/args.dart';

import 'command_support.dart';

Future<int> runBuildClient(
  String cwd,
  Args args,
  StringSink out,
  StringSink err,
) async {
  return runCommand(err, () async {
    await loadCommandConfig(cwd, args);
    out.writeln('client build is not implemented yet');
    return 0;
  });
}
