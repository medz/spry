import 'package:coal/args.dart';
import 'package:spry/builder.dart' show BuildConfig, loadConfig;

Future<int> runCommand(StringSink err, Future<int> Function() action) async {
  try {
    return await action();
  } catch (error) {
    err.writeln(error);
    return 1;
  }
}

Future<BuildConfig> loadCommandConfig(
  String cwd,
  Args args, {
  Map<String, dynamic> overrides = const {},
}) {
  return loadConfig(
    configPath: stringArg(args, 'config'),
    overrides: {'rootDir': cwd, ...overrides},
  );
}

String? stringArg(Args args, String key) => args[key]?.safeAs<String>();
