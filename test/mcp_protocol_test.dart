import 'package:spry/src/mcp/mcp_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('JsonRpcRequest', () {
    test('parses a request with params', () {
      final json = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'tools/call',
        'params': {'name': 'spry.list_routes'},
      };

      final request = JsonRpcRequest.fromJson(json);

      expect(request.jsonrpc, '2.0');
      expect(request.id, 1);
      expect(request.method, 'tools/call');
      expect(request.params, {'name': 'spry.list_routes'});
    });

    test('parses a request without params', () {
      final json = {'jsonrpc': '2.0', 'id': 2, 'method': 'tools/list'};

      final request = JsonRpcRequest.fromJson(json);

      expect(request.params, isNull);
    });

    test('parses a notification (null id)', () {
      final json = {
        'jsonrpc': '2.0',
        'id': null,
        'method': 'notifications/initialized',
      };

      final request = JsonRpcRequest.fromJson(json);

      expect(request.id, isNull);
      expect(request.method, 'notifications/initialized');
    });

    test('serializes to JSON-compatible map', () {
      final request = const JsonRpcRequest(
        jsonrpc: '2.0',
        id: 1,
        method: 'initialize',
        params: {'protocolVersion': '2024-11-05'},
      );

      final map = request.toJson();

      expect(map['jsonrpc'], '2.0');
      expect(map['id'], 1);
      expect(map['method'], 'initialize');
      expect(map['params'], {'protocolVersion': '2024-11-05'});
    });

    test('serializes without params when null', () {
      final request = const JsonRpcRequest(
        jsonrpc: '2.0',
        id: 1,
        method: 'tools/list',
      );

      final map = request.toJson();

      expect(map.containsKey('params'), isFalse);
    });
  });

  group('JsonRpcResponse', () {
    test('result factory creates success response', () {
      final response = JsonRpcResponse.result(1, {'key': 'value'});

      expect(response.jsonrpc, '2.0');
      expect(response.id, 1);
      expect(response.result, {'key': 'value'});
    });

    test('serializes success response', () {
      final response = JsonRpcResponse.result(1, {'tools': []});

      final map = response.toJson();

      expect(map['jsonrpc'], '2.0');
      expect(map['id'], 1);
      expect(map['result'], {'tools': []});
      expect(map.containsKey('error'), isFalse);
    });
  });

  group('JsonRpcError', () {
    test('methodNotFound factory creates error', () {
      final error = JsonRpcError.methodNotFound(1, 'foo');

      expect(error.jsonrpc, '2.0');
      expect(error.id, 1);
      expect(error.code, JsonRpcErrors.methodNotFound);
      expect(error.message, 'Method not found: foo');
    });

    test('invalidParams factory creates error', () {
      final error = JsonRpcError.invalidParams(2, 'Missing tool name');

      expect(error.code, JsonRpcErrors.invalidParams);
      expect(error.id, 2);
      expect(error.message, 'Missing tool name');
    });

    test('parseError factory creates error with null id', () {
      final error = JsonRpcError.parseError(message: 'Bad JSON');

      expect(error.code, JsonRpcErrors.parseError);
      expect(error.id, isNull);
      expect(error.message, 'Bad JSON');
    });

    test('internalError factory creates error', () {
      final error = JsonRpcError.internalError(3, 'Something broke');

      expect(error.code, JsonRpcErrors.internalError);
      expect(error.id, 3);
      expect(error.message, 'Something broke');
    });

    test('serializes to JSON-compatible map', () {
      final error = JsonRpcError.methodNotFound(1, 'test');

      final map = error.toJson();

      expect(map['jsonrpc'], '2.0');
      expect(map['id'], 1);
      expect(map['error'], {
        'code': JsonRpcErrors.methodNotFound,
        'message': 'Method not found: test',
      });
    });

    test('serializes with optional data', () {
      final error = JsonRpcError(
        jsonrpc: '2.0',
        id: 1,
        code: -32603,
        message: 'Internal error',
        data: {'detail': 'stack trace here'},
      );

      final map = error.toJson();

      expect(map['error']['data'], {'detail': 'stack trace here'});
    });
  });

  group('JsonRpcErrors', () {
    test('defines standard error codes', () {
      expect(JsonRpcErrors.parseError, -32700);
      expect(JsonRpcErrors.invalidRequest, -32600);
      expect(JsonRpcErrors.methodNotFound, -32601);
      expect(JsonRpcErrors.invalidParams, -32602);
      expect(JsonRpcErrors.internalError, -32603);
    });
  });

  group('MCP protocol constants', () {
    test('jsonRpcVersion is 2.0', () {
      expect(jsonRpcVersion, '2.0');
    });

    test('latestProtocolVersion is 2024-11-05', () {
      expect(latestProtocolVersion, '2024-11-05');
    });
  });
}
