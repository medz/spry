import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'utils/find_root.dart';
import 'utils/get_packages.dart';

final edotor = YamlEditor('''
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: daily
  - package-ecosystem: pub
    directory: /
    schedule:
      interval: daily
    commit-message:
      prefix: fix
  - package-ecosystem: npm
    directory: /docs
    schedule:
      interval: daily
''');

void main() {
  final dependabot = File(join(findRoot(), '.github', 'dependabot.yml'));
  final contents = dependabot.readAsStringSync();

  for (final package in getPackages()) {
    edotor.appendToList(
      ['updates'],
      {
        'package-ecosystem': 'pub',
        'directory': '/$package',
        'schedule': {'interval': 'daily'},
        'commit-message': {'prefix': 'fix'},
      },
    );
  }

  if (contents != edotor.toString()) {
    dependabot.writeAsStringSync(edotor.toString());
    print(true);
  }
}
