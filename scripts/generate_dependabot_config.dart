import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'utils/find_root.dart';
import 'utils/get_packages.dart';

final edotor = YamlEditor('''
version: 2
updates:
  # Workflows
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: daily

  # Workspace
  - package-ecosystem: pub
    directory: /
    schedule:
      interval: daily
    labels:
      - workspace
      - deps

  # Docs
  - package-ecosystem: npm
    directory: /docs
    schedule:
      interval: daily
    labels:
      - docs
      - deps
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
        'labels': [basename(package), 'deps'],
      },
    );
  }

  if (contents != edotor.toString()) {
    dependabot.writeAsStringSync(edotor.toString());
    print(true);
  }
}
