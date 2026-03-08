import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';

Future<void> writeGeneratedFiles(
  List<GeneratedFile> files,
  BuildConfig config,
) async {
  final outputDir = Directory(p.join(config.rootDir, config.outputDir));
  await outputDir.create(recursive: true);

  for (final file in files) {
    final target = File(p.join(outputDir.path, file.path));
    await target.parent.create(recursive: true);
    await target.writeAsString(file.content);
  }
}
