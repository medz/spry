import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'utils/find_root.dart';

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
  final root = findRoot();
  final config =
      loadYaml(File(join(root, 'pubspec.yaml')).readAsStringSync())['spry'];

  // Update version
  denpendabot.update(['version'], config['dependabot_version']);

  final context = Context(current: root, style: style);
  final globs = (config['packages'] as Iterable).cast<String>().map((e) {
    final pattern = join(e, 'pubspec.yaml');

    return Glob(pattern, context: context);
  });

  final packages = globs
      .map((e) => e.listSync(root: root))
      .reduce((value, element) => [...value, ...element])
      .where((element) =>
          element.statSync().type == FileSystemEntityType.file &&
          element.existsSync())
      .map((e) => context.relative(e.dirname))
      .toSet();

  packages.forEach((package) {
    denpendabot.appendToList(
      ['updates'],
      {
        'package-ecosystem': 'pub',
        'directory': '/$package',
        'schedule': {'interval': 'daily'},
        'labels': [basename(package), 'deps'],
      },
    );
  });

  stdout.write(denpendabot.toString());
}
