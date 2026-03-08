import 'dart:convert';
import 'dart:io';

import 'package:coal/args.dart';
import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';

import 'tools/bun.dart';
import 'write.dart';

typedef ProcessStarter =
    Future<Process> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      Map<String, String>? environment,
      bool includeParentEnvironment,
      bool runInShell,
      ProcessStartMode mode,
    });

Future<int> runServe(
  String cwd,
  Args args,
  StringSink out,
  StringSink err, {
  ProcessRunner processRunner = Process.run,
  ProcessStarter processStarter = Process.start,
  BunInstaller? installBun,
}) async {
  try {
    final config = await loadConfig(
      configPath: _string(args, 'config'),
      overrides: {'rootDir': cwd},
    );
    final tree = await scan(config);
    final files = await generate(tree, config);
    await writeGeneratedFiles(files, config);

    final outputDir = p.join(config.rootDir, config.outputDir);
    final outputMain = p.join(config.outputDir, 'main.dart');

    switch (config.target) {
      case BuildTarget.dart:
        final process = await processStarter(
          Platform.resolvedExecutable,
          ['run', outputMain],
          workingDirectory: config.rootDir,
          runInShell: Platform.isWindows,
          mode: ProcessStartMode.inheritStdio,
          includeParentEnvironment: true,
        );
        return await process.exitCode;
      case BuildTarget.node:
      case BuildTarget.bun:
      case BuildTarget.cloudflare:
      case BuildTarget.vercel:
        final compile = await processRunner(
          Platform.resolvedExecutable,
          [
            'compile',
            'js',
            outputMain,
            '-o',
            p.join(config.outputDir, 'main.js'),
          ],
          workingDirectory: config.rootDir,
          runInShell: Platform.isWindows,
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );
        if (compile.exitCode != 0) {
          err.writeln((compile.stderr as String).trim());
          return compile.exitCode;
        }

        final bun = await resolveBunExecutable(
          config.rootDir,
          processRunner: processRunner,
          installBun: installBun,
        );

        final (workingDirectory, arguments) = switch (config.target) {
          BuildTarget.node || BuildTarget.bun => (
            config.rootDir,
            [p.join(config.outputDir, 'main.js')],
          ),
          BuildTarget.cloudflare => (
            outputDir,
            [
              'x',
              'wrangler',
              'dev',
              '_worker.mjs',
              '--ip',
              config.host,
              '--port',
              '${config.port}',
              '--no-bundle',
            ],
          ),
          BuildTarget.vercel => (
            outputDir,
            ['x', 'vercel', 'dev', '--port', '${config.port}'],
          ),
          BuildTarget.dart => throw StateError('unreachable'),
        };

        final process = await processStarter(
          bun,
          arguments,
          workingDirectory: workingDirectory,
          runInShell: Platform.isWindows,
          mode: ProcessStartMode.inheritStdio,
          includeParentEnvironment: true,
        );
        return await process.exitCode;
    }
  } catch (error) {
    err.writeln(error);
    return 1;
  }
}

String? _string(Args args, String key) => args[key]?.safeAs<String>();
