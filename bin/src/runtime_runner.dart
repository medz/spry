import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart' show BuildConfig;
import 'package:spry/config.dart';

import 'build_pipeline.dart';
import 'tools/bun.dart';

final class RunnerSpec {
  const RunnerSpec({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
  });

  final String executable;
  final List<String> arguments;
  final String workingDirectory;
}

final class ServePlan {
  const ServePlan({required this.spec, required this.supportsHotSwap});

  final RunnerSpec spec;
  final bool supportsHotSwap;
}

Future<ServePlan> createServePlan(
  BuildResult build, {
  required ProcessRunner processRunner,
  required BunInstaller? installBun,
}) async {
  final config = build.config;
  switch (config.target) {
    case BuildTarget.vm:
      return ServePlan(
        spec: RunnerSpec(
          executable: Platform.resolvedExecutable,
          arguments: ['run', p.join(config.outputDir, 'src', 'main.dart')],
          workingDirectory: config.rootDir,
        ),
        supportsHotSwap: false,
      );
    case BuildTarget.dartExe:
      return ServePlan(
        spec: RunnerSpec(
          executable: p.join(
            config.rootDir,
            config.outputDir,
            'dart',
            'server',
          ),
          arguments: [],
          workingDirectory: config.rootDir,
        ),
        supportsHotSwap: false,
      );
    case BuildTarget.dartAot:
      return ServePlan(
        spec: RunnerSpec(
          executable: Platform.resolvedExecutable,
          arguments: ['run', p.join(config.outputDir, 'dart', 'server.aot')],
          workingDirectory: config.rootDir,
        ),
        supportsHotSwap: false,
      );
    case BuildTarget.dartJit:
      return ServePlan(
        spec: RunnerSpec(
          executable: Platform.resolvedExecutable,
          arguments: ['run', p.join(config.outputDir, 'dart', 'server.jit')],
          workingDirectory: config.rootDir,
        ),
        supportsHotSwap: false,
      );
    case BuildTarget.dartKernel:
      return ServePlan(
        spec: RunnerSpec(
          executable: Platform.resolvedExecutable,
          arguments: ['run', p.join(config.outputDir, 'dart', 'server.dill')],
          workingDirectory: config.rootDir,
        ),
        supportsHotSwap: false,
      );
    case BuildTarget.deno:
      return ServePlan(
        spec: RunnerSpec(
          executable: 'deno',
          arguments: [
            'run',
            '--allow-net',
            p.join(config.outputDir, 'deno', 'index.js'),
          ],
          workingDirectory: config.rootDir,
        ),
        supportsHotSwap: false,
      );
    case BuildTarget.node:
    case BuildTarget.bun:
    case BuildTarget.cloudflare:
    case BuildTarget.vercel:
    case BuildTarget.netlify:
      final bun = await resolveBunExecutable(
        config.rootDir,
        processRunner: processRunner,
        installBun: installBun,
      );
      if (config.target == BuildTarget.vercel) {
        await _ensureVercelWorkspaceReady(
          config,
          bunExecutable: bun,
          processRunner: processRunner,
        );
      }
      final wranglerConfigPath = build.targetCheck.wranglerConfigPath;
      return ServePlan(
        spec: switch (config.target) {
          BuildTarget.node => RunnerSpec(
            executable: bun,
            arguments: [p.join(config.outputDir, 'node', 'index.cjs')],
            workingDirectory: config.rootDir,
          ),
          BuildTarget.bun => RunnerSpec(
            executable: bun,
            arguments: [p.join(config.outputDir, 'bun', 'index.js')],
            workingDirectory: config.rootDir,
          ),
          BuildTarget.cloudflare => RunnerSpec(
            executable: bun,
            arguments: [
              'x',
              'wrangler',
              'dev',
              if (wranglerConfigPath != null) '--config',
              if (wranglerConfigPath != null)
                p.relative(wranglerConfigPath, from: config.rootDir),
              if (wranglerConfigPath == null)
                p.join(config.outputDir, 'cloudflare', 'index.js'),
              '--ip',
              config.host,
              '--port',
              '${config.port}',
            ],
            workingDirectory: config.rootDir,
          ),
          BuildTarget.vercel => RunnerSpec(
            executable: bun,
            arguments: [
              'x',
              'vercel',
              'dev',
              '--local',
              '--yes',
              '--listen',
              '${config.host}:${config.port}',
            ],
            workingDirectory: p.join(
              config.rootDir,
              config.outputDir,
              'vercel',
            ),
          ),
          BuildTarget.netlify => RunnerSpec(
            executable: bun,
            arguments: ['x', 'netlify', 'dev', '--port', '${config.port}'],
            workingDirectory: p.join(
              config.rootDir,
              config.outputDir,
              'netlify',
            ),
          ),
          _ => throw StateError('unreachable'),
        },
        supportsHotSwap: switch (config.target) {
          BuildTarget.cloudflare ||
          BuildTarget.vercel ||
          BuildTarget.netlify => true,
          _ => false,
        },
      );
  }
}

Future<void> _ensureVercelWorkspaceReady(
  BuildConfig config, {
  required String bunExecutable,
  required ProcessRunner processRunner,
}) async {
  final workspace = p.join(config.rootDir, config.outputDir, 'vercel');
  final packageJson = File(p.join(workspace, 'package.json'));
  if (!packageJson.existsSync()) {
    return;
  }

  final helpersDir = Directory(
    p.join(workspace, 'node_modules', '@vercel', 'functions'),
  );
  if (helpersDir.existsSync()) {
    return;
  }

  await ensureBunDependencies(
    bunExecutable,
    workspace,
    processRunner: processRunner,
  );
}

bool sameRunnerSpec(RunnerSpec a, RunnerSpec b) {
  if (a.executable != b.executable ||
      a.workingDirectory != b.workingDirectory) {
    return false;
  }
  if (a.arguments.length != b.arguments.length) {
    return false;
  }
  for (var i = 0; i < a.arguments.length; i++) {
    if (a.arguments[i] != b.arguments[i]) {
      return false;
    }
  }
  return true;
}
