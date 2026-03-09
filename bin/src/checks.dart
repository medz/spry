import 'dart:io';
import 'dart:convert';

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
    BuildTarget.vercel => _checkVercelSetup(config),
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

Future<TargetCheckResult> _checkVercelSetup(BuildConfig config) async {
  final vercelConfig = File(p.join(config.rootDir, 'vercel.json'));
  if (await vercelConfig.exists()) {
    final json = jsonDecode(await vercelConfig.readAsString());
    final outputDirectory = json is Map<String, Object?>
        ? json['outputDirectory']
        : null;
    if (outputDirectory != 'public') {
      throw StateError('vercel.json must set "outputDirectory" to "public".');
    }
    final rewrites = json is Map<String, Object?> ? json['rewrites'] : null;
    final hasExpectedRewrite =
        rewrites is List &&
        rewrites.any(
          (it) =>
              it is Map<String, Object?> &&
              it['source'] == '/(.*)' &&
              (it['destination'] == '/api' ||
                  it['destination'] == '/api/index'),
        );
    if (!hasExpectedRewrite) {
      throw StateError(
        'vercel.json must rewrite "/(.*)" to "/api" or "/api/index".',
      );
    }
  }

  return const TargetCheckResult();
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
        )
        .firstMatch(source)
        ?.group(1);
  }

  return RegExp(r'"main"\s*:\s*"([^"]+)"').firstMatch(source)?.group(1);
}
