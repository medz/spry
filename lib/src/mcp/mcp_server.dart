import 'dart:convert';
import 'dart:io';

import '../../version.dart';
import '../builder/config.dart';
import '../builder/scan_entry.dart';
import 'mcp_protocol.dart';
import 'mcp_tools.dart';

/// Runs the Spry MCP server over stdin/stdout.
///
/// Reads newline-delimited JSON-RPC messages, dispatches them,
/// and writes responses. Loops until stdin closes.
Future<void> runMcpServer({
  required BuildConfig config,
  required List<ScanEntry> entries,
}) async {
  final state = ProjectState(config: config, entries: entries);

  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) continue;

      final request = JsonRpcRequest.fromJson(decoded);
      // Skip writing responses for notifications (no id).
      if (request.id == null) continue;

      final response = _dispatch(request, state);
      writeResponse(response);
    } on FormatException catch (e) {
      writeResponse(
        JsonRpcResponse.error(
          null,
          JsonRpcErrors.parseError,
          'Parse error: ${e.message}',
        ),
      );
    } on ArgumentError catch (e) {
      writeResponse(
        JsonRpcResponse.error(
          null,
          JsonRpcErrors.invalidRequest,
          'Invalid request: ${e.message}',
        ),
      );
    }
  }
}

/// Dispatches a JSON-RPC request to the appropriate handler.
JsonRpcResponse _dispatch(JsonRpcRequest request, ProjectState state) {
  return switch (request.method) {
    'initialize' => _handleInitialize(request),
    'tools/list' => _handleToolsList(request),
    'tools/call' => _handleToolsCall(request, state),
    _ => JsonRpcResponse.error(
      request.id,
      JsonRpcErrors.methodNotFound,
      'Method not found: ${request.method}',
    ),
  };
}

/// Handles the MCP initialize request.
JsonRpcResponse _handleInitialize(JsonRpcRequest request) {
  return JsonRpcResponse.result(request.id, {
    'protocolVersion': '2024-11-05',
    'capabilities': {'tools': {}},
    'serverInfo': {'name': 'spry-mcp', 'version': version},
  });
}

/// Handles the tools/list request.
JsonRpcResponse _handleToolsList(JsonRpcRequest request) {
  final tools = [
    for (final tool in toolDefinitions)
      {
        'name': tool.name,
        'description': tool.description,
        'inputSchema': tool.inputSchema,
      },
  ];

  return JsonRpcResponse.result(request.id, {'tools': tools});
}

/// Handles the tools/call request.
JsonRpcResponse _handleToolsCall(JsonRpcRequest request, ProjectState state) {
  final params = request.params;
  if (params == null) {
    return JsonRpcResponse.error(
      request.id,
      JsonRpcErrors.invalidParams,
      'Missing params',
    );
  }

  final toolName = params['name'] as String?;
  if (toolName == null) {
    return JsonRpcResponse.error(
      request.id,
      JsonRpcErrors.invalidParams,
      'Missing tool name',
    );
  }

  final toolArgs = params['arguments'] as Map<String, dynamic>?;

  try {
    final result = handleToolCall(toolName, toolArgs, state);
    return JsonRpcResponse.result(request.id, {
      'content': [
        {'type': 'text', 'text': _formatResult(result)},
      ],
    });
  } on ArgumentError catch (e) {
    return JsonRpcResponse.error(
      request.id,
      JsonRpcErrors.invalidParams,
      'Invalid params: ${e.message}',
    );
  }
}

/// Formats a tool result as a human-readable string.
String _formatResult(Object? result) {
  if (result == null) return '';
  if (result is String) return result;

  try {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(result);
  } catch (_) {
    return result.toString();
  }
}
