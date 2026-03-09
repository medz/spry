import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;

import 'src/build.dart';
import 'src/serve.dart';

Future<void> main(List<String> args) async {
  final cwd = p.normalize(p.absolute(Directory.current.path));
  final out = stdout;
  final err = stderr;
  final parsed = Args.parse(
    args,
    aliases: {'h': 'help', 'c': 'config', 'o': 'output', 'r': 'root'},
    bool: ['help'],
    string: ['config', 'output', 'root'],
  );

  if (parsed['help']?.safeAs<bool>() == true) {
    out.writeln(_usage);
    exit(0);
  }

  if (parsed.rest.isEmpty) {
    out.writeln(_usage);
    exit(64);
  }

  final command = parsed.rest.first;
  final code = await switch (command) {
    'build' => runBuild(cwd, parsed, out, err),
    'serve' => runServe(cwd, parsed, out, err),
    _ => () async {
      err.writeln('Unknown command: $command');
      err.writeln(_usage);
      return 64;
    }(),
  };
  exit(code);
}

const _usage = '''
Usage:
  spry build [--root <dir>] [--config <file>] [--output <dir>]
  spry serve [--root <dir>] [--config <file>]

Options:
  -r, --root    Project root directory
  -c, --config  Config file path, resolved from --root
  -o, --output  Build output directory
  -h, --help    Show this help
''';
