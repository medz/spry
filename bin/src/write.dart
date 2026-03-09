import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';

Future<void> writeGeneratedFiles(
  List<GeneratedFile> files,
  BuildConfig config,
) async {
  final outputDir = Directory(p.join(config.rootDir, config.outputDir));
  await _recreateOutputDir(outputDir);

  for (final file in files) {
    final baseDir = file.rootRelative ? config.rootDir : outputDir.path;
    final target = File(p.join(baseDir, file.path));
    if (file.writeIfMissing && await target.exists()) {
      continue;
    }
    await target.parent.create(recursive: true);
    await target.writeAsString(file.content);
  }

  await _syncPublicDir(config);
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

Future<void> _syncPublicDir(BuildConfig config) async {
  final source = Directory(p.join(config.rootDir, config.publicDir));
  final targets = <Directory>[
    if (config.target == BuildTarget.vercel)
      Directory(p.join(config.rootDir, config.outputDir, 'vercel', 'public')),
  ];

  if (targets.isEmpty) {
    return;
  }

  for (final target in targets) {
    await target.create(recursive: true);
  }

  if (!await source.exists()) {
    return;
  }

  await for (final entity in source.list(recursive: true)) {
    final relative = p.relative(entity.path, from: source.path);
    for (final target in targets) {
      final destination = p.join(target.path, relative);
      if (entity is Directory) {
        await Directory(destination).create(recursive: true);
        continue;
      }
      if (entity is File) {
        await File(destination).parent.create(recursive: true);
        await entity.copy(destination);
      }
    }
  }
}
