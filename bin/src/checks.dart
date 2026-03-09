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
      'Warning: no Wrangler config found. Add `main = "${config.outputDir}/cloudflare.mjs"` to wrangler.toml or set `wranglerConfig` in spry.config.dart.',
    );
    return const TargetCheckResult();
  }

  final main = await _readMainField(discovered);
  final expected = '${config.outputDir}/cloudflare.mjs';
  if (main != expected && main != './$expected') {
    throw StateError(
      'Wrangler config `${p.relative(discovered, from: config.rootDir)}` must set `main` to `$expected`.',
    );
  }

  return TargetCheckResult(wranglerConfigPath: discovered);
}

Future<String?> _resolveWranglerConfig(BuildConfig config) async {
  if (config.wranglerConfig case final explicit?) {
    final path = p.normalize(p.absolute(config.rootDir, explicit));
    return await File(path).exists() ? path : null;
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
