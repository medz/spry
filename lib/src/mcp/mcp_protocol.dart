import 'dart:convert';
import 'dart:io';

/// JSON-RPC 2.0 version string used by all MCP messages.
const jsonRpcVersion = '2.0';

/// Latest MCP protocol version supported by this server.
const latestProtocolVersion = '2024-11-05';

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

/// A successful JSON-RPC 2.0 response sent back to the MCP client.
final class JsonRpcResponse {
  /// Creates a JSON-RPC success response.
  const JsonRpcResponse({
    required this.jsonrpc,
    required this.id,
    required this.result,
  });

  /// Creates a success response with a [result] payload.
  factory JsonRpcResponse.result(Object? id, Object? result) {
    return JsonRpcResponse(jsonrpc: jsonRpcVersion, id: id, result: result);
  }

  /// Protocol version (always `'2.0'`).
  final String jsonrpc;

  /// Request identifier; matches the request that triggered this response.
  final Object? id;

  /// Success payload.
  final Object? result;

  /// Serializes this response to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    'result': result,
  };
}

/// A JSON-RPC 2.0 error response.
final class JsonRpcError {
  /// Creates a JSON-RPC error response.
  const JsonRpcError({
    required this.jsonrpc,
    required this.id,
    required this.code,
    required this.message,
    this.data,
  });

  /// Creates a parse error response.
  factory JsonRpcError.parseError({String? message}) => JsonRpcError(
    jsonrpc: jsonRpcVersion,
    id: null,
    code: JsonRpcErrors.parseError,
    message: message ?? 'Parse error',
  );

  /// Creates a method-not-found error response.
  factory JsonRpcError.methodNotFound(Object? id, String method) =>
      JsonRpcError(
        jsonrpc: jsonRpcVersion,
        id: id,
        code: JsonRpcErrors.methodNotFound,
        message: 'Method not found: $method',
      );

  /// Creates an invalid-params error response.
  factory JsonRpcError.invalidParams(Object? id, String message) =>
      JsonRpcError(
        jsonrpc: jsonRpcVersion,
        id: id,
        code: JsonRpcErrors.invalidParams,
        message: message,
      );

  /// Creates an internal error response.
  factory JsonRpcError.internalError(Object? id, String message) =>
      JsonRpcError(
        jsonrpc: jsonRpcVersion,
        id: id,
        code: JsonRpcErrors.internalError,
        message: message,
      );

  /// Protocol version (always `'2.0'`).
  final String jsonrpc;

  /// Request identifier.
  final Object? id;

  /// Error code per JSON-RPC 2.0.
  final int code;

  /// Human-readable error message.
  final String message;

  /// Optional additional error data.
  final Object? data;

  /// Serializes this error to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    'error': {'code': code, 'message': message, if (data != null) 'data': data},
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

/// Writes a JSON-RPC success response as a single JSON line to stdout.
void writeResponse(JsonRpcResponse response) {
  stdout.writeln(jsonEncode(response.toJson()));
}

/// Writes a JSON-RPC error response as a single JSON line to stdout.
void writeError(JsonRpcError error) {
  stdout.writeln(jsonEncode(error.toJson()));
}
