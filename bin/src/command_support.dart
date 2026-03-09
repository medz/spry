import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
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
  final rootDir = resolveCommandRoot(cwd, args);
  return loadConfig(
    configPath: stringArg(args, 'config'),
    overrides: {'rootDir': rootDir, ...overrides},
  );
}

String? stringArg(Args args, String key) => args[key]?.safeAs<String>();

String resolveCommandRoot(String cwd, Args args) {
  final root = stringArg(args, 'root');
  if (root == null || root.isEmpty) {
    return cwd;
  }
  return p.normalize(p.absolute(cwd, root));
}
