import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../build_pipeline.dart' show ProcessRunner;

typedef BunInstaller = Future<String> Function(String cwd);

Future<String> resolveBunExecutable(
  String cwd, {
  Map<String, String>? environment,
  ProcessRunner processRunner = Process.run,
  BunInstaller? installBun,
}) async {
  final systemBun = findBunInPath(environment: environment);
  if (systemBun != null &&
      await _isRunnable(
        systemBun,
        cwd: cwd,
        environment: environment,
        processRunner: processRunner,
      )) {
    return systemBun;
  }

  final localBun = projectBunExecutablePath(cwd);
  if (await _isRunnable(
    localBun,
    cwd: cwd,
    environment: environment,
    processRunner: processRunner,
  )) {
    return localBun;
  }

  final install =
      installBun ??
      (String cwd) => installProjectBun(
        cwd,
        environment: environment,
        processRunner: processRunner,
      );
  final installed = await install(cwd);
  if (await _isRunnable(
    installed,
    cwd: cwd,
    environment: environment,
    processRunner: processRunner,
  )) {
    return installed;
  }

  throw StateError('Unable to resolve a Bun executable.');
}

Future<String> installProjectBun(
  String cwd, {
  Map<String, String>? environment,
  ProcessRunner processRunner = Process.run,
}) async {
  final installRoot = projectBunInstallRoot(cwd);
  await Directory(installRoot).create(recursive: true);

  final result = await switch (Platform.isWindows) {
    true => processRunner(
      'powershell',
      [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        'irm bun.com/install.ps1 | iex',
      ],
      workingDirectory: cwd,
      environment: _installationEnvironment(installRoot, environment),
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ),
    false => processRunner(
      '/bin/sh',
      ['-c', 'curl -fsSL https://bun.com/install | bash'],
      workingDirectory: cwd,
      environment: _installationEnvironment(installRoot, environment),
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ),
  };

  if (result.exitCode != 0) {
    throw StateError(
      'Failed to install Bun into $installRoot:\n${(result.stderr as String).trim()}',
    );
  }

  return projectBunExecutablePath(cwd);
}

String projectBunInstallRoot(String cwd) {
  return p.join(cwd, '.spry', 'tools', 'bun');
}

Map<String, String> _installationEnvironment(
  String installRoot,
  Map<String, String>? environment,
) {
  return {...?environment, 'BUN_INSTALL': installRoot};
}

String projectBunExecutablePath(String cwd) {
  return p.join(
    projectBunInstallRoot(cwd),
    'bin',
    Platform.isWindows ? 'bun.exe' : 'bun',
  );
}

Future<void> ensureBunDependencies(
  String executable,
  String cwd, {
  ProcessRunner processRunner = Process.run,
}) async {
  final result = await processRunner(
    executable,
    ['install'],
    workingDirectory: cwd,
    runInShell: Platform.isWindows,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'Failed to install Bun dependencies in $cwd:\n${(result.stderr as String).trim()}',
    );
  }
}

String? findBunInPath({Map<String, String>? environment}) {
  final path = (environment ?? Platform.environment)['PATH'];
  if (path == null || path.isEmpty) {
    return null;
  }

  for (final dir in path.split(Platform.isWindows ? ';' : ':')) {
    if (dir.isEmpty) {
      continue;
    }

    final candidate = p.join(dir, Platform.isWindows ? 'bun.exe' : 'bun');
    if (File(candidate).existsSync()) {
      return candidate;
    }
  }

  return null;
}

Future<bool> _isRunnable(
  String executable, {
  required String cwd,
  required Map<String, String>? environment,
  required ProcessRunner processRunner,
}) async {
  final file = File(executable);
  if (!file.existsSync()) {
    return false;
  }

  final result = await processRunner(
    executable,
    ['--version'],
    workingDirectory: cwd,
    environment: environment,
    runInShell: Platform.isWindows,
  );
  return result.exitCode == 0;
}
