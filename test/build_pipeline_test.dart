import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/config.dart';
import 'package:spry/src/builder/config.dart';
import 'package:test/test.dart';

import '../bin/src/build_pipeline.dart';

void main() {
  for (final (target, output) in [
    (BuildTarget.node, p.join('.spry', 'node', 'runtime', 'main.js')),
    (BuildTarget.kernel, p.join('.spry', 'dart', 'server.dill')),
    (BuildTarget.vm, null),
  ]) {
    test(
      '${target.name} build metadata includes known compiler output',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'spry_build_metadata_',
        );
        addTearDown(() => root.delete(recursive: true));
        final compiled = <String>[];
        final build = await buildProject(
          BuildConfig(rootDir: root.path, target: target),
          out: StringBuffer(),
          processRunner:
              (
                executable,
                arguments, {
                workingDirectory,
                environment,
                runInShell = false,
                stdoutEncoding,
                stderrEncoding,
              }) async {
                compiled.add(arguments[arguments.indexOf('-o') + 1]);
                return ProcessResult(0, 0, '', '');
              },
        );
        final artifacts = build.generatedArtifacts
            .where((artifact) => artifact.type == 'compiledRuntime')
            .toList();
        if (output == null) {
          expect(compiled, isEmpty);
          expect(artifacts, isEmpty);
        } else {
          expect(compiled, [output]);
          expect(artifacts, [(type: 'compiledRuntime', path: output)]);
        }
        // Preserve the CLI's historical generator-only count.
        expect(
          build.generatedArtifacts.length,
          build.generatedFileCount + artifacts.length,
        );
      },
    );
  }
}
