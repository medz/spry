import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

/// Find Spry root directory.
String findRoot() => _searchRoot(Platform.script.path);

/// Search for the root directory.
///
/// Find the `pubspec.yaml` and spry is not null
String _searchRoot(String path) {
  final pubspec = File(join(path, 'pubspec.yaml'));
  if (pubspec.existsSync()) {
    final document = loadYaml(pubspec.readAsStringSync());
    if (document['spry'] != null) {
      return path;
    }
  }

  // If path is filesystem root, throw an error.
  final parent = dirname(path);
  if (parent == path) {
    throw Exception('Could not find Spry root directory.');
  }

  return _searchRoot(parent);
}
