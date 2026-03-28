import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/builder.dart';
import 'package:spry/config.dart';

final class TargetCheckResult {
  const TargetCheckResult({this.wranglerConfigPath});

  final String? wranglerConfigPath;
}

Future<TargetCheckResult> checkTargetSetup(
  BuildConfig config,
  StringSink out,
) async {
  return switch (config.target) {
    BuildTarget.cloudflare => _checkCloudflareSetup(config, out),
    // Netlify uses a generated workspace under `.spry/netlify/`, and the
    // required host bootstrap files are emitted directly by `write.dart` and
    // launched through `runtime_runner.dart`, so there is no external config
    // file to validate ahead of time.
    BuildTarget.netlify => const TargetCheckResult(),
    _ => const TargetCheckResult(),
  };
}

Future<TargetCheckResult> _checkCloudflareSetup(
  BuildConfig config,
  StringSink out,
) async {
  final discovered = await _resolveWranglerConfig(config);
  if (discovered == null) {
    out.writeln(
      'Warning: no Wrangler config found. Add `main = "${p.posix.join(config.outputDir, 'cloudflare', 'index.js')}"` to wrangler.toml or set `wranglerConfig` in spry.config.dart.',
    );
    return const TargetCheckResult();
  }

  final main = await _readMainField(discovered);
  final expected = p.posix.join(config.outputDir, 'cloudflare', 'index.js');
  if (main != expected && main != './$expected') {
    throw StateError(
      'Wrangler config `${p.relative(discovered, from: config.rootDir)}` must set `main` to `$expected`.',
    );
  }

  final assetsDirectory = await _readAssetsDirectory(discovered);
  if (assetsDirectory == null) {
    out.writeln(
      'Warning: Wrangler config `${p.relative(discovered, from: config.rootDir)}` should set `assets.directory` to your public assets directory.',
    );
  } else {
    final expectedAssets = config.publicDir;
    final normalized = assetsDirectory.startsWith('./')
        ? assetsDirectory.substring(2)
        : assetsDirectory;
    if (normalized != expectedAssets) {
      out.writeln(
        'Warning: Wrangler config `${p.relative(discovered, from: config.rootDir)}` should set `assets.directory` to `$expectedAssets`.',
      );
    }
  }

  return TargetCheckResult(wranglerConfigPath: discovered);
}

Future<String?> _resolveWranglerConfig(BuildConfig config) async {
  if (config.wranglerConfig case final explicit?) {
    final path = p.normalize(p.absolute(config.rootDir, explicit));
    if (await File(path).exists()) {
      return path;
    }
    throw StateError(
      'Configured wranglerConfig `${p.relative(path, from: config.rootDir)}` was not found.',
    );
  }

  for (final candidate in const [
    'wrangler.jsonc',
    'wrangler.json',
    'wrangler.toml',
  ]) {
    final path = p.join(config.rootDir, candidate);
    if (await File(path).exists()) {
      return path;
    }
  }
  return null;
}

Future<String?> _readMainField(String configPath) async {
  final source = await File(configPath).readAsString();
  final name = p.basename(configPath);
  if (name.endsWith('.toml')) {
    return RegExp(
      '^\\s*main\\s*=\\s*["\\\']([^"\\\']+)["\\\']',
      multiLine: true,
    ).firstMatch(source)?.group(1);
  }

  return RegExp(r'"main"\s*:\s*"([^"]+)"').firstMatch(source)?.group(1);
}

Future<String?> _readAssetsDirectory(String configPath) async {
  final source = await File(configPath).readAsString();
  final name = p.basename(configPath);
  if (name.endsWith('.toml')) {
    return _readTomlAssetsField(source, 'directory');
  }

  return _readJsonAssetsField(source, 'directory');
}

String? _readTomlAssetsField(String source, String field) {
  var inAssets = false;
  for (final line in source.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      inAssets = trimmed == '[assets]';
      continue;
    }
    if (!inAssets) {
      continue;
    }

    final quoted = RegExp(
      '^$field\\s*=\\s*["\\\']([^"\\\']+)["\\\']\$',
    ).firstMatch(trimmed);
    if (quoted != null) {
      return quoted.group(1);
    }
  }
  return null;
}

String? _readJsonAssetsField(String source, String field) {
  final assetsBlock = RegExp(
    r'"assets"\s*:\s*\{([\s\S]*?)\}',
  ).firstMatch(source)?.group(1);
  if (assetsBlock == null) {
    return null;
  }

  return RegExp('"$field"\\s*:\\s*"([^"]+)"').firstMatch(assetsBlock)?.group(1);
}
