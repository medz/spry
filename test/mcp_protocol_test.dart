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

      final json = request.toJson();

      expect(json['jsonrpc'], '2.0');
      expect(json['id'], 1);
      expect(json['method'], 'initialize');
      expect(json['params'], {'protocolVersion': '2024-11-05'});
    });

    test('serializes without params when null', () {
      final request = const JsonRpcRequest(
        jsonrpc: '2.0',
        id: 1,
        method: 'tools/list',
      );

      final json = request.toJson();

      expect(json.containsKey('params'), isFalse);
    });
  });

  group('JsonRpcResponse', () {
    test('result factory creates success response', () {
      final response = JsonRpcResponse.result(1, {'key': 'value'});

      expect(response.jsonrpc, '2.0');
      expect(response.id, 1);
      expect(response.result, {'key': 'value'});
      expect(response.error, isNull);
    });

    test('error factory creates error response', () {
      final response = JsonRpcResponse.error(
        1,
        JsonRpcErrors.methodNotFound,
        'Method not found: foo',
      );

      expect(response.jsonrpc, '2.0');
      expect(response.id, 1);
      expect(response.result, isNull);
      expect(response.error, {
        'code': JsonRpcErrors.methodNotFound,
        'message': 'Method not found: foo',
      });
    });

    test('serializes success response', () {
      final response = JsonRpcResponse.result(1, {'tools': []});

      final json = response.toJson();

      expect(json['jsonrpc'], '2.0');
      expect(json['id'], 1);
      expect(json['result'], {'tools': []});
      expect(json.containsKey('error'), isFalse);
    });

    test('serializes error response', () {
      final response = JsonRpcResponse.error(
        null,
        JsonRpcErrors.parseError,
        'Parse error',
      );

      final json = response.toJson();

      expect(json['jsonrpc'], '2.0');
      expect(json['id'], isNull);
      expect(json.containsKey('result'), isFalse);
      expect(json['error'], {
        'code': JsonRpcErrors.parseError,
        'message': 'Parse error',
      });
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
}
