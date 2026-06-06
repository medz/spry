import 'package:coal/args.dart';
import 'package:spry/src/builder/scanner.dart';
import 'package:spry/src/mcp/mcp_server.dart';

import 'command_support.dart';

/// Runs `spry mcp` — starts a local MCP server for AI tool inspection.
Future<int> runMcp(String cwd, Args args, StringSink out, StringSink err) {
  return runCommand(err, () async {
    final config = await loadCommandConfig(cwd, args);
    final entries = await scan(config).toList();

    err.writeln('Spry MCP server ready (target: ${config.target.name})');

    await runMcpServer(config: config, entries: entries);
    return 0;
  });
}
