import 'dart:convert';
import 'dart:io';

import '../../version.dart';
import '../builder/config.dart';
import '../builder/scan_entry.dart';
import 'mcp_protocol.dart';
import 'mcp_tools.dart';

/// Runs the Spry MCP server over stdin/stdout.
///
/// Implements the Model Context Protocol (MCP) 2024-11-05 over
/// newline-delimited JSON-RPC 2.0 on stdio.
///
/// Reads JSON-RPC messages, dispatches them, and writes responses.
/// Loops until stdin closes or the client disconnects.
Future<void> runMcpServer({
  required BuildConfig config,
  required List<ScanEntry> entries,
  Future<ProjectState> Function()? reloadState,
}) async {
  var state = ProjectState(config: config, entries: entries);

  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    try {
      final decoded = jsonDecode(trimmed);
      final request = JsonRpcRequest.fromJson(decoded);
      if (!request.isNotification &&
          reloadState != null &&
          (request.method == 'initialize' || request.method == 'tools/call')) {
        try {
          state = await reloadState();
        } catch (error) {
          writeError(
            JsonRpcError.internalError(
              request.id,
              'Failed to refresh project state: $error',
            ),
          );
          continue;
        }
      }
      _handleMessage(request, state);
    } on FormatException catch (e) {
      writeError(JsonRpcError.parseError(message: e.message));
    } on JsonRpcError catch (e) {
      writeError(e);
    }
  }
}

/// Routes a JSON-RPC message to the appropriate handler.
void _handleMessage(JsonRpcRequest request, ProjectState state) {
  // Notifications: no id → no response expected.
  if (request.isNotification) {
    handleNotification(request, state);
    return;
  }

  try {
    final response = dispatch(request, state);
    writeResponse(response);
  } on JsonRpcError catch (e) {
    writeError(e);
  }
}

/// Handles an MCP notification (no response).
///
/// Exposed publicly for use by non-stdio transports.
void handleNotification(JsonRpcRequest request, ProjectState state) {
  switch (request.method) {
    case 'notifications/initialized':
      // Client confirms initialization is complete. No action needed.
      break;
    case 'notifications/cancelled':
      // Client cancelled a request. Ignored in this stateless implementation.
      break;
    default:
      // Unknown notification — silently ignored per JSON-RPC spec.
      break;
  }
}

/// Dispatches a JSON-RPC request to the appropriate handler.
///
/// Exposed publicly for use by non-stdio transports.
JsonRpcResponse dispatch(JsonRpcRequest request, ProjectState state) {
  return switch (request.method) {
    'initialize' => _handleInitialize(request, state),
    'tools/list' => _handleToolsList(request),
    'tools/call' => _handleToolsCall(request, state),
    'ping' => JsonRpcResponse.result(request.id, {}),
    _ => throw JsonRpcError.methodNotFound(request.id, request.method),
  };
}

/// Returns the server instructions string used by both initialize
/// and the separate instructions endpoint.
String _serverInstructions(ProjectState state) {
  final cfg = state.config;
  return 'Spry MCP server for ${cfg.target.name} target. '
      'Use spry.list_routes to see all routes, '
      'spry.explain_route to debug a specific request, '
      'spry.get_config to inspect configuration, and '
      'spry.get_project_info for a project overview. '
      '${state.routeEntries.length} routes available.';
}

/// Handles the MCP initialize request.
///
/// Per the MCP spec: returns protocolVersion, capabilities, serverInfo,
/// and optional instructions for the LLM.
JsonRpcResponse _handleInitialize(JsonRpcRequest request, ProjectState state) {
  return JsonRpcResponse.result(request.id, {
    'protocolVersion': latestProtocolVersion,
    'capabilities': {'tools': {}},
    'serverInfo': {'name': 'spry-mcp', 'version': version},
    'instructions': _serverInstructions(state),
  });
}

/// Handles the tools/list request.
///
/// Returns all available tool definitions with name, description,
/// and JSON Schema input descriptors.
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
///
/// Dispatches the tool by name and returns the result as MCP content.
/// Tool-level errors are returned with `isError: true` in the result
/// rather than as JSON-RPC errors, per the MCP spec.
JsonRpcResponse _handleToolsCall(JsonRpcRequest request, ProjectState state) {
  final params = request.params;
  if (params == null) {
    return _toolError(request.id, 'missing params');
  }

  final toolName = params['name'];
  if (toolName is! String) {
    return _toolError(request.id, 'tool name must be a string');
  }

  final toolArgs = params['arguments'];

  try {
    if (toolArgs != null && toolArgs is! Map<String, dynamic>) {
      throw ArgumentError('tool arguments must be a JSON object');
    }
    final result = handleToolCall(
      toolName,
      toolArgs as Map<String, dynamic>?,
      state,
    );
    return JsonRpcResponse.result(request.id, {
      'content': [
        {'type': 'text', 'text': _formatResult(result)},
      ],
    });
  } catch (error) {
    // Tool failures are content errors; a failed inspection must not drop
    // the stdio connection or prevent subsequent requests.
    return _toolError(
      request.id,
      error is ArgumentError ? '${error.message}' : '$error',
    );
  }
}

JsonRpcResponse _toolError(Object? id, String message) =>
    JsonRpcResponse.result(id, {
      'content': [
        {'type': 'text', 'text': 'Error: $message'},
      ],
      'isError': true,
    });

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
