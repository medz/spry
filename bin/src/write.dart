import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';

Future<void> writeGeneratedFiles(
  List<GeneratedFile> files,
  BuildConfig config,
) async {
  final outputDir = Directory(p.join(config.rootDir, config.outputDir));
  await outputDir.create(recursive: true);
  await _removeStaleGeneratedFiles(outputDir.path);

  for (final file in files) {
    final target = File(p.join(outputDir.path, file.path));
    await target.parent.create(recursive: true);
    await target.writeAsString(file.content);
  }
}

Future<void> _removeStaleGeneratedFiles(String outputDir) async {
  for (final relativePath in _generatedFilePaths) {
    final target = File(p.join(outputDir, relativePath));
    if (await target.exists()) {
      await target.delete();
    }
  }

  final apiDir = Directory(p.join(outputDir, 'api'));
  if (await apiDir.exists() && (await apiDir.list().isEmpty)) {
    await apiDir.delete();
  }
}

const _generatedFilePaths = <String>[
  'app.dart',
  'app.g.dart',
  'hooks.g.dart',
  'main.dart',
  'main.g.dart',
  'cloudflare.mjs',
  '_worker.mjs',
  'api/index.mjs',
  'vercel.json',
  'package.json',
];
