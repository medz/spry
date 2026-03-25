import 'package:path/path.dart' as p;

import '../../config.dart';

import 'config.dart';
import 'generated_file.dart';

/// Runtime-specific generation details for a build target.
final class TargetSpec {
  /// Creates a target specification.
  const TargetSpec({
    required this.runtimeImport,
    required this.mainBody,
    this.compiledJsOutput,
    this.dartCompileSubcommand,
    this.dartCompileOutput,
    this.extraFiles = const [],
  });

  /// Import used by the generated `src/main.dart`.
  final String runtimeImport;

  /// Generated `main()` body.
  final String mainBody;

  /// Output path for compiled JavaScript, when applicable.
  final String? compiledJsOutput;

  /// `dart compile` subcommand for Dart compilation targets, e.g. `'exe'`,
  /// `'aot-snapshot'`, `'jit-snapshot'`, `'kernel'`.
  final String? dartCompileSubcommand;

  /// Output path for the compiled Dart artifact, when [dartCompileSubcommand]
  /// is set.
  final String? dartCompileOutput;

  /// Extra generated files required by the target.
  final List<GeneratedFile> extraFiles;
}

TargetSpec _dartSpec(
  BuildConfig config, {
  String? dartCompileSubcommand,
  String? dartCompileOutput,
}) => TargetSpec(
  runtimeImport: "import 'package:spry/osrv/dart.dart';",
  mainBody: _serveBody(host: config.host, port: config.port),
  dartCompileSubcommand: dartCompileSubcommand,
  dartCompileOutput: dartCompileOutput,
);

/// Builds the generation specification for [config.target].
TargetSpec buildTargetSpec(BuildConfig config) {
  return switch (config.target) {
    BuildTarget.vm => _dartSpec(config),
    BuildTarget.exe => _dartSpec(
      config,
      dartCompileSubcommand: 'exe',
      dartCompileOutput: p.join(config.outputDir, 'dart', 'server'),
    ),
    BuildTarget.aot => _dartSpec(
      config,
      dartCompileSubcommand: 'aot-snapshot',
      dartCompileOutput: p.join(config.outputDir, 'dart', 'server.aot'),
    ),
    BuildTarget.jit => _dartSpec(
      config,
      dartCompileSubcommand: 'jit-snapshot',
      dartCompileOutput: p.join(config.outputDir, 'dart', 'server.jit'),
    ),
    BuildTarget.kernel => _dartSpec(
      config,
      dartCompileSubcommand: 'kernel',
      dartCompileOutput: p.join(config.outputDir, 'dart', 'server.dill'),
    ),
    BuildTarget.node => TargetSpec(
      runtimeImport: "import 'package:spry/osrv/node.dart';",
      mainBody: _serveBody(host: config.host, port: config.port),
      compiledJsOutput: p.join(config.outputDir, 'node', 'runtime', 'main.js'),
      extraFiles: const [
        GeneratedFile(path: 'node/index.cjs', content: _nodeEntry),
      ],
    ),
    BuildTarget.bun => TargetSpec(
      runtimeImport: "import 'package:spry/osrv/bun.dart';",
      mainBody: _serveBody(host: config.host, port: config.port),
      compiledJsOutput: p.join(config.outputDir, 'bun', 'index.js'),
    ),
    BuildTarget.deno => TargetSpec(
      runtimeImport: "import 'package:spry/osrv/deno.dart';",
      mainBody: _serveBody(host: config.host, port: config.port),
      compiledJsOutput: p.join(config.outputDir, 'deno', 'index.js'),
    ),
    BuildTarget.cloudflare => TargetSpec(
      runtimeImport: "import 'package:spry/osrv/cloudflare.dart' as \$entry;",
      mainBody: _fetchEntryBody(r'$entry.defineFetchExport(server);'),
      compiledJsOutput: p.join(config.outputDir, 'cloudflare', 'main.js'),
      extraFiles: [
        GeneratedFile(path: 'cloudflare/index.js', content: _cloudflareWorker),
      ],
    ),
    BuildTarget.vercel => TargetSpec(
      runtimeImport: "import 'package:spry/osrv/vercel.dart' as \$entry;",
      mainBody: _fetchEntryBody(r'$entry.defineFetchExport(server);'),
      compiledJsOutput: p.join(
        config.outputDir,
        'vercel',
        'runtime',
        'main.js',
      ),
      extraFiles: const [
        GeneratedFile(path: 'vercel/api/index.mjs', content: _vercelEntry),
        GeneratedFile(path: 'vercel/vercel.json', content: _vercelConfig),
        GeneratedFile(path: 'vercel/package.json', content: _vercelPackageJson),
      ],
    ),
    BuildTarget.netlify => TargetSpec(
      runtimeImport: "import 'package:spry/osrv/netlify.dart' as \$entry;",
      mainBody: _fetchEntryBody(r'$entry.defineFetchExport(server);'),
      compiledJsOutput: p.join(
        config.outputDir,
        'netlify',
        'runtime',
        'main.js',
      ),
      extraFiles: const [
        GeneratedFile(
          path: 'netlify/functions/index.mjs',
          content: _netlifyEntry,
        ),
        GeneratedFile(path: 'netlify/netlify.toml', content: _netlifyConfig),
      ],
    ),
  };
}

String _serveBody({required String host, required int port}) {
  return "Future<void> main() async {\n"
      "  final server = Server(\n"
      "    fetch: app.fetch,\n"
      "    onStart: \$hooks.onStart,\n"
      "    onStop: \$hooks.onStop,\n"
      "    onError: \$hooks.onError,\n"
      "  );\n"
      "  final runtime = await serve(\n"
      "    server,\n"
      "    host: '${_escape(host)}',\n"
      "    port: $port,\n"
      "  );\n"
      "  await runtime.closed;\n"
      "}";
}

String _fetchEntryBody(String defineFetchEntryCall) {
  return "void main() {\n"
      "  final server = Server(\n"
      "    fetch: app.fetch,\n"
      "    onStart: \$hooks.onStart,\n"
      "    onStop: \$hooks.onStop,\n"
      "    onError: \$hooks.onError,\n"
      "  );\n"
      "  $defineFetchEntryCall\n"
      "}";
}

String _escape(String value) =>
    value.replaceAll(r'$', r'\$').replaceAll("'", r"\'");

const _cloudflareWorker = """
// Generated by spry - do not edit.
import './main.js';

export default { fetch: globalThis.__osrv_fetch__ };
""";

const _nodeEntry = """
// Generated by spry - do not edit.
globalThis.self ??= globalThis;
require('./runtime/main.js');
""";

const _vercelEntry = """
// Generated by spry - do not edit.
globalThis.self ??= globalThis;
import '../runtime/main.js';

export default { fetch: globalThis.__osrv_fetch__ };
""";

const _vercelConfig = """
{
  "\$schema": "https://openapi.vercel.sh/vercel.json",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/api"
    }
  ]
}
""";

const _vercelPackageJson = """
{
  "private": true,
  "dependencies": {
    "@vercel/functions": "^3.4.3"
  }
}
""";

const _netlifyEntry = """
// Generated by spry - do not edit.
globalThis.self ??= globalThis;
import '../runtime/main.js';

export default globalThis.__osrv_fetch__;
""";

const _netlifyConfig = """
[build]
publish = "public"

[functions]
directory = "functions"

[[redirects]]
from = "/*"
to = "/.netlify/functions/index"
status = 200
""";
