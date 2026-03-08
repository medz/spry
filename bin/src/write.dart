import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';

Future<void> writeGeneratedFiles(
  List<GeneratedFile> files,
  BuildConfig config,
) async {
  final outputDir = Directory(p.join(config.rootDir, config.outputDir));
  await _recreateOutputDir(outputDir);

  for (final file in files) {
    final target = File(p.join(outputDir.path, file.path));
    await target.parent.create(recursive: true);
    await target.writeAsString(file.content);
  }
}

Future<void> _recreateOutputDir(Directory outputDir) async {
  if (await outputDir.exists()) {
    await for (final entity in outputDir.list(recursive: false)) {
      if (p.basename(entity.path) == 'tools') {
        continue;
      }
      await entity.delete(recursive: true);
    }
  } else {
    await outputDir.create(recursive: true);
  }
}
