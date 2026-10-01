import 'package:coal/args.dart';
import 'package:spry/src/builder/scanner.dart';
import 'package:spry/src/mcp/mcp_server.dart';
import 'package:spry/src/mcp/mcp_tools.dart' show ProjectState;

import 'command_support.dart';

/// Runs `spry mcp` — starts a local MCP server for AI tool inspection.
Future<int> runMcp(String cwd, Args args, StringSink out, StringSink err) {
  return runCommand(err, () async {
    Future<ProjectState> loadState() async {
      final config = await loadCommandConfig(cwd, args);
      return ProjectState(config: config, entries: await scan(config).toList());
    }

    final state = await loadState();
    err.writeln('Spry MCP server ready (target: ${state.config.target.name})');
    await runMcpServer(
      config: state.config,
      entries: state.entries,
      reloadState: loadState,
    );
    return 0;
  });
}
