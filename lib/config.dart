import 'dart:convert';
import 'dart:io';

/// Supported deployment targets for a Spry application.
enum BuildTarget {
  /// Runs the application on the Dart VM.
  dart,

  /// Compiles the application for the Node.js runtime.
  node,

  /// Compiles the application for the Bun runtime.
  bun,

  /// Compiles the application for the Cloudflare Workers runtime.
  cloudflare,

  /// Compiles the application for the Vercel runtime.
  vercel,
}

/// Reload behavior used by `spry serve`.
enum ReloadStrategy {
  /// Restarts the runtime process after a rebuild.
  restart,

  /// Keeps the runtime process alive when the target supports hotswap.
  hotswap,
}

/// Emits Spry build configuration as JSON for `spry.config.dart`.
void defineSpryConfig({
  /// Overrides the host used by `spry serve`.
  String? host,

  /// Overrides the port used by `spry serve`.
  int? port,

  /// Selects the target runtime.
  BuildTarget? target,

  /// Overrides the routes directory.
  String? routesDir,

  /// Overrides the middleware directory.
  String? middlewareDir,

  /// Overrides the public asset directory.
  String? publicDir,

  /// Overrides the generated output directory.
  String? outputDir,

  /// Overrides the reload strategy used by `spry serve`.
  ReloadStrategy? reload,

  /// Overrides the Wrangler config path for Cloudflare targets.
  String? wranglerConfig,
}) {
  stdout.writeln(
    json.encode({
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (target != null) 'target': target.name,
      if (routesDir != null) 'routesDir': routesDir,
      if (middlewareDir != null) 'middlewareDir': middlewareDir,
      if (publicDir != null) 'publicDir': publicDir,
      if (outputDir != null) 'outputDir': outputDir,
      if (reload != null) 'reload': reload.name,
      if (wranglerConfig != null) 'wranglerConfig': wranglerConfig,
    }),
  );
}
