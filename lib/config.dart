import 'dart:convert';
import 'dart:io';

/// Supported deployment targets for a Spry application.
enum BuildTarget {
  /// Runs the application on the Dart VM (dev/serve mode, no compilation).
  vm,

  /// Compiles the application to a native executable using `dart compile exe`.
  dartExe,

  /// Compiles the application to an AOT snapshot using `dart compile aot-snapshot`.
  dartAot,

  /// Compiles the application to a JIT snapshot using `dart compile jit-snapshot`.
  dartJit,

  /// Compiles the application to a kernel snapshot using `dart compile kernel`.
  dartKernel,

  /// Compiles the application for the Node.js runtime.
  node,

  /// Compiles the application for the Bun runtime.
  bun,

  /// Compiles the application for the Deno runtime.
  deno,

  /// Compiles the application for the Cloudflare Workers runtime.
  cloudflare,

  /// Compiles the application for the Vercel runtime.
  vercel,

  /// Compiles the application for the Netlify Functions runtime.
  netlify,
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
  final config = <String, Object>{};
  if (host != null) {
    config['host'] = host;
  }
  if (port != null) {
    config['port'] = port;
  }
  if (target != null) {
    config['target'] = target.name;
  }
  if (routesDir != null) {
    config['routesDir'] = routesDir;
  }
  if (middlewareDir != null) {
    config['middlewareDir'] = middlewareDir;
  }
  if (publicDir != null) {
    config['publicDir'] = publicDir;
  }
  if (outputDir != null) {
    config['outputDir'] = outputDir;
  }
  if (reload != null) {
    config['reload'] = reload.name;
  }
  if (wranglerConfig != null) {
    config['wranglerConfig'] = wranglerConfig;
  }

  stdout.writeln(json.encode(config));
}
