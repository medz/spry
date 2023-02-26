import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'utils/get_packages.dart';

final denpendabot = YamlEditor('''
version: null
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
  for (final package in getPackages()) {
    denpendabot.appendToList(
      ['updates'],
      {
        'package-ecosystem': 'pub',
        'directory': '/$package',
        'schedule': {'interval': 'daily'},
        'labels': [basename(package), 'deps'],
      },
    );
  }

  stdout.write(denpendabot.toString());
}
