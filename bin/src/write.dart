import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';

final class WriteGeneratedResult {
  const WriteGeneratedResult({
    required this.generatedFileCount,
    required this.generatedSourcePaths,
    required this.generatedClientFileCount,
  });

  final int generatedFileCount;
  final List<String> generatedSourcePaths;
  final int generatedClientFileCount;
}

Future<WriteGeneratedResult> writeGeneratedFiles(
  List<GeneratedFile> files,
  BuildConfig config,
) async {
  return writeGeneratedEntries(
    Stream.fromIterable(
      files.map(
        (file) => GeneratedEntry.fromGeneratedFile(
          file,
          type: generatedEntryTypeForFile(file, config),
        ),
      ),
    ),
    config,
  );
}

Future<WriteGeneratedResult> writeGeneratedEntries(
  Stream<GeneratedEntry> entries,
  BuildConfig config, {
  bool recreateOutputDir = true,
  bool syncPublicDir = true,
}) async {
  final rootDir = p.normalize(p.absolute(config.rootDir));
  final outputPath = _resolveOutputDir(rootDir, config.outputDir);
  final outputDir = Directory(outputPath);
  if (recreateOutputDir) {
    await _recreateOutputDir(outputDir);
  }

  var generatedFileCount = 0;
  var generatedClientFileCount = 0;
  final generatedSourcePaths = <String>[];
  await for (final entry in entries) {
    final targetPath = _resolveGeneratedEntryPath(
      rootDir,
      outputDir.path,
      entry,
    );
    final target = File(targetPath);
    if (entry.writeIfMissing && await target.exists()) {
      continue;
    }
    await target.parent.create(recursive: true);
    await target.writeAsString(entry.content);
    generatedFileCount++;
    if (entry.type == GeneratedEntryType.clientSource) {
      generatedClientFileCount++;
    }
    if (entry.rootRelative &&
        (targetPath == rootDir || p.isWithin(rootDir, targetPath)) &&
        !p.isWithin(outputDir.path, targetPath) &&
        !p.equals(outputDir.path, targetPath)) {
      generatedSourcePaths.add(
        p.normalize(p.relative(targetPath, from: rootDir)),
      );
    }
  }

  if (syncPublicDir) {
    await _syncPublicDir(config, rootDir, outputPath);
  }

  return WriteGeneratedResult(
    generatedFileCount: generatedFileCount,
    generatedSourcePaths: generatedSourcePaths,
    generatedClientFileCount: generatedClientFileCount,
  );
}

String _resolveOutputDir(String rootDir, String outputDir) {
  final outputPath = p.normalize(p.absolute(rootDir, outputDir));
  if (outputPath == rootDir || !p.isWithin(rootDir, outputPath)) {
    throw ArgumentError.value(
      outputDir,
      'config.outputDir',
      'must resolve to a subdirectory of rootDir',
    );
  }
  return outputPath;
}

String _resolveChildPath(
  String baseDir,
  String childPath, {
  required String argumentName,
  bool allowBaseDir = false,
}) {
  final targetPath = p.normalize(p.absolute(baseDir, childPath));
  if ((!allowBaseDir && targetPath == baseDir) ||
      (targetPath != baseDir && !p.isWithin(baseDir, targetPath))) {
    throw ArgumentError.value(
      childPath,
      argumentName,
      'must stay within ${p.basename(baseDir)}',
    );
  }
  return targetPath;
}

String _resolveGeneratedEntryPath(
  String rootDir,
  String outputDir,
  GeneratedEntry entry,
) {
  if (!entry.rootRelative) {
    return _resolveChildPath(outputDir, entry.path, argumentName: 'file.path');
  }

  final targetPath = p.normalize(p.absolute(rootDir, entry.path));
  if (targetPath == rootDir || p.isWithin(rootDir, targetPath)) {
    return targetPath;
  }
  if (entry.type == GeneratedEntryType.clientSource) {
    return targetPath;
  }
  throw ArgumentError.value(
    entry.path,
    'file.path',
    'must stay within ${p.basename(rootDir)}',
  );
}

Future<void> _recreateOutputDir(Directory outputDir) async {
  if (await outputDir.exists()) {
    await for (final entity in outputDir.list(
      recursive: false,
      followLinks: false,
    )) {
      if (p.basename(entity.path) == 'tools') {
        continue;
      }
      await entity.delete(recursive: true);
    }
  } else {
    await outputDir.create(recursive: true);
  }
}

Future<void> _syncPublicDir(
  BuildConfig config,
  String rootDir,
  String outputPath,
) async {
  final sourcePath = _resolveChildPath(
    rootDir,
    config.publicDir,
    argumentName: 'config.publicDir',
    allowBaseDir: true,
  );
  final source = Directory(sourcePath);
  final targets = <Directory>[
    if (config.target == BuildTarget.vercel)
      Directory(p.join(outputPath, 'vercel', 'public')),
    if (config.target == BuildTarget.netlify)
      Directory(p.join(outputPath, 'netlify', 'public')),
    if (config.target == BuildTarget.exe ||
        config.target == BuildTarget.aot ||
        config.target == BuildTarget.jit ||
        config.target == BuildTarget.kernel)
      Directory(p.join(outputPath, 'dart', 'public')),
  ];

  if (targets.isEmpty) {
    return;
  }

  for (final target in targets) {
    final targetPath = p.normalize(p.absolute(target.path));
    if (targetPath == sourcePath || p.isWithin(sourcePath, targetPath)) {
      throw ArgumentError.value(
        config.publicDir,
        'config.publicDir',
        'must not include the build output directory',
      );
    }
  }

  for (final target in targets) {
    await target.create(recursive: true);
  }

  if (!await source.exists()) {
    return;
  }

  await for (final entity in source.list(recursive: true, followLinks: false)) {
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
