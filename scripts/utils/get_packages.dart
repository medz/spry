import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart';

import 'find_root.dart';
import 'get_root_pubspec.dart';

/// Get packages
Iterable<String> getPackages() {
  final root = findRoot();
  final config = getRootPubspec()['spry'];
  final context = Context(current: root, style: style);
  final globs = (config['packages'] as Iterable).cast<String>().map((e) {
    final pattern = join(e, 'pubspec.yaml');

    return Glob(pattern, context: context);
  });

  return globs
      .map((e) => e.listSync(root: root))
      .reduce((value, element) => [...value, ...element])
      .where((element) =>
          element.statSync().type == FileSystemEntityType.file &&
          element.existsSync())
      .map((e) => context.relative(e.dirname))
      .toList()
    ..sort();
}
