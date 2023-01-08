import 'dart:io';

import 'package:args/args.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';
import 'package:spry_fsrouter/spry_fsrouter.dart';

void main(Iterable<String> arguments) {
  final ArgParser parser = ArgParser();
  parser.addOption('path', abbr: 'p', defaultsTo: 'lib/app');
  parser.addFlag('help', abbr: 'h', negatable: false);

  final ArgResults results = parser.parse(arguments);
  if (results['help'] as bool) {
    print(parser.usage);
    return;
  }

  final String path = results['path'] as String;
  final Builder builder = Builder.fromDirectory(path);
  final Library library = Library(builder);
  final DartFormatter formatter = DartFormatter();
  final DartEmitter emitter = DartEmitter(
    allocator: Allocator.simplePrefixing(),
    orderDirectives: true,
  );

  final String code = formatter.format(library.accept(emitter).toString());
  File(join(path, 'app.dart')).writeAsStringSync(code);

  print('Generated spry routes (app.dart) in the `$path` directory.');
}
