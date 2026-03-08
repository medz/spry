import 'dart:io';

import 'src/cli.dart';

Future<void> main(List<String> args) async {
  final code = await runCli(args);
  exit(code);
}
