import 'dart:convert';
import 'dart:io';

enum BuildTarget { dart, node, bun, cloudflare, vercel }

enum ReloadStrategy { restart, hotswap }

void defineSpryConfig({
  String? host,
  int? port,
  BuildTarget? target,
  String? routesDir,
  String? middlewareDir,
  String? outputDir,
  ReloadStrategy? reload,
}) {
  stdout.writeln(
    json.encode({
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (target != null) 'target': target.name,
      if (routesDir != null) 'routesDir': routesDir,
      if (middlewareDir != null) 'middlewareDir': middlewareDir,
      if (outputDir != null) 'outputDir': outputDir,
      if (reload != null) 'reload': reload.name,
    }),
  );
}
