import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';

import 'write.dart';

Future<int> runCli(
  List<String> args, {
  String? currentDirectory,
  StringSink? stdoutSink,
  StringSink? stderrSink,
}) async {
  final cwd = p.normalize(
    p.absolute(currentDirectory ?? Directory.current.path),
  );
  final out = stdoutSink ?? stdout;
  final err = stderrSink ?? stderr;
  final parsed = Args.parse(
    args,
    aliases: {'h': 'help'},
    bool: ['help'],
    string: [
      'target',
      'output',
      'routes',
      'middleware',
      'host',
      'port',
      'reload',
    ],
  );

  if (parsed['help']?.safeAs<bool>() == true) {
    out.writeln(_usage);
    return 0;
  }

  if (parsed.rest.isEmpty) {
    out.writeln(_usage);
    return 64;
  }

  final command = parsed.rest.first;

  return switch (command) {
    'build' => _runBuild(cwd, parsed, out, err),
    'serve' => _runServe(cwd, parsed, out, err),
    _ => () async {
      err.writeln('Unknown command: $command');
      err.writeln(_usage);
      return 64;
    }(),
  };
}

Future<int> _runBuild(
  String cwd,
  Args args,
  StringSink out,
  StringSink err,
) async {
  try {
    final config = await loadConfig(
      overrides: {
        'rootDir': cwd,
        if (_string(args, 'target') case final value?) 'target': value,
        if (_string(args, 'output') case final value?) 'outputDir': value,
        if (_string(args, 'routes') case final value?) 'routesDir': value,
        if (_string(args, 'middleware') case final value?)
          'middlewareDir': value,
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

Future<int> _runServe(
  String cwd,
  Args args,
  StringSink out,
  StringSink err,
) async {
  try {
    final config = await loadConfig(
      overrides: {
        'rootDir': cwd,
        if (_string(args, 'host') case final value?) 'host': value,
        if (_string(args, 'port') case final value?)
          'port': int.tryParse(value),
        if (_string(args, 'routes') case final value?) 'routesDir': value,
        if (_string(args, 'middleware') case final value?)
          'middlewareDir': value,
        if (_string(args, 'reload') case final value?) 'reload': value,
      },
    );
    final tree = await scan(config);
    final files = await generate(tree, config);
    await writeGeneratedFiles(files, config);
    out.writeln('Generated ${files.length} file(s) into ${config.outputDir}');
    err.writeln('serve is not implemented yet');
    return 2;
  } catch (error) {
    err.writeln(error);
    return 1;
  }
}

String? _string(Args args, String key) => args[key]?.safeAs<String>();

const _usage = '''
Usage:
  spry build [--target <target>] [--output <dir>] [--routes <dir>] [--middleware <dir>]
  spry serve [--host <host>] [--port <port>] [--routes <dir>] [--middleware <dir>] [--reload <strategy>]
''';
