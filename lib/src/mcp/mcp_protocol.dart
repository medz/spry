import 'dart:convert';
import 'dart:io';

/// A JSON-RPC 2.0 request message received from the MCP client.
final class JsonRpcRequest {
  /// Creates a JSON-RPC request from its constituent parts.
  const JsonRpcRequest({
    required this.jsonrpc,
    required this.id,
    required this.method,
    this.params,
  });

  /// Parses a JSON-RPC request from a decoded JSON map.
  factory JsonRpcRequest.fromJson(Map<String, dynamic> json) {
    return JsonRpcRequest(
      jsonrpc: json['jsonrpc'] as String,
      id: json['id'],
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }

  /// Protocol version (always `'2.0'`).
  final String jsonrpc;

  /// Request identifier; `null` for notifications.
  final Object? id;

  /// RPC method name.
  final String method;

  /// Optional named parameters.
  final Map<String, dynamic>? params;

  /// Serializes this request to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    'method': method,
    if (params != null) 'params': params,
  };
}

/// A JSON-RPC 2.0 response sent back to the MCP client.
final class JsonRpcResponse {
  /// Creates a JSON-RPC response from its constituent parts.
  const JsonRpcResponse({
    required this.jsonrpc,
    required this.id,
    this.result,
    this.error,
  });

  /// Creates a successful JSON-RPC response with a [result] payload.
  factory JsonRpcResponse.result(Object? id, Object? result) {
    return JsonRpcResponse(jsonrpc: '2.0', id: id, result: result);
  }

  /// Creates a JSON-RPC error response.
  factory JsonRpcResponse.error(Object? id, int code, String message) {
    return JsonRpcResponse(
      jsonrpc: '2.0',
      id: id,
      error: {'code': code, 'message': message},
    );
  }

  /// Protocol version (always `'2.0'`).
  final String jsonrpc;

  /// Request identifier; matches the request that triggered this response.
  final Object? id;

  /// Success payload; absent on errors.
  final Object? result;

  /// Error payload with `code` and `message`; absent on success.
  final Map<String, dynamic>? error;

  /// Serializes this response to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    if (result != null) 'result': result,
    if (error != null) 'error': error,
  };
}

/// JSON-RPC 2.0 standard error codes.
abstract final class JsonRpcErrors {
  /// The JSON received could not be parsed.
  static const parseError = -32700;

  /// The JSON is not a valid request.
  static const invalidRequest = -32600;

  /// The requested method does not exist.
  static const methodNotFound = -32601;

  /// Invalid method parameters.
  static const invalidParams = -32602;

  /// Internal JSON-RPC error.
  static const internalError = -32603;
}

/// Reads newline-delimited JSON-RPC messages from stdin.
Stream<JsonRpcRequest> readMessages() {
  return stdin.transform(utf8.decoder).transform(const LineSplitter()).map((
    line,
  ) {
    final json = jsonDecode(line) as Map<String, dynamic>;
    return JsonRpcRequest.fromJson(json);
  });
}

/// Writes a JSON-RPC response as a single JSON line to stdout.
void writeResponse(JsonRpcResponse response) {
  stdout.writeln(jsonEncode(response.toJson()));
}
