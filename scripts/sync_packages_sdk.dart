import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'utils/find_root.dart';
import 'utils/get_packages.dart';
import 'utils/get_root_pubspec.dart';

main() {
  final root = findRoot();
  final sdk = getRootPubspec()['environment']['sdk'];
  bool updated = false;

  for (final package in getPackages()) {
    final pubspec = File(join(root, package, 'pubspec.yaml'));
    final contents = pubspec.readAsStringSync();
    final editor = YamlEditor(contents);
    editor.update(['environment', 'sdk'], sdk);

    if (contents != editor.toString()) {
      pubspec.writeAsStringSync(editor.toString());
      updated = true;
    }
  }

  print(updated);
}
