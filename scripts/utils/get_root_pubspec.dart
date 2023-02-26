import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import 'find_root.dart';

/// Get root pubspec
Map<String, dynamic> getRootPubspec() {
  final root = findRoot();
  final pubspec = loadYaml(File(join(root, 'pubspec.yaml')).readAsStringSync());

  if (pubspec is Map) {
    return pubspec.cast();
  }

  throw StateError('Invalid pubspec.yaml');
}
